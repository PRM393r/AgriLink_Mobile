import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:share_plus/share_plus.dart';
import 'package:socket_io_client/socket_io_client.dart' as sio;
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

// Mock shipper — backend chưa có bảng shipper thật, giả lập để hiện UI liên hệ.
const _kMockShipperName = 'Nguyễn Văn Giao';
const _kMockShipperPhone = '0909123456';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;
  final String orderCode;
  final String? token;

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
    required this.orderCode,
    this.token,
  });

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();

  LatLng _shipperPos = const LatLng(10.7769, 106.7009);
  final List<LatLng> _routePoints = [];

  bool _arrived = false;
  bool _connected = false;
  int _estimatedMinutes = 0;
  int _stepIndex = 0;
  int _totalSteps = 0;
  String? _error;

  sio.Socket? _socket;

  // Smooth marker animation
  late AnimationController _markerAnimController;
  late Animation<double> _markerAnim;
  LatLng _prevPos = const LatLng(10.7769, 106.7009);
  LatLng _targetPos = const LatLng(10.7769, 106.7009);

  @override
  void initState() {
    super.initState();
    _markerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _markerAnim = CurvedAnimation(
      parent: _markerAnimController,
      curve: Curves.easeInOut,
    );
    _markerAnim.addListener(_onMarkerAnimTick);
    _connectSocket();
  }

  void _connectSocket() {
    try {
      _socket = sio.io(
        ApiConstants.trackingSocketUrl,
        sio.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .build(),
      );

      _socket!.onConnect((_) {
        if (mounted) setState(() => _connected = true);
        _socket!.emit('track:join', {
          'orderId': widget.orderId,
          'token': widget.token ?? '',
        });
      });

      _socket!.onDisconnect((_) {
        if (mounted) setState(() => _connected = false);
      });

      _socket!.onConnectError((_) {
        if (mounted) setState(() => _error = 'Không thể kết nối tracking server');
      });

      _socket!.on('track:location', (data) {
        if (!mounted) return;
        final lat = (data['lat'] as num).toDouble();
        final lng = (data['lng'] as num).toDouble();
        final newPos = LatLng(lat, lng);

        setState(() {
          _estimatedMinutes = (data['estimatedMinutes'] as num?)?.toInt() ?? 0;
          _stepIndex = (data['stepIndex'] as num?)?.toInt() ?? 0;
          _totalSteps = (data['totalSteps'] as num?)?.toInt() ?? 1;
          _routePoints.add(newPos);
          _prevPos = _shipperPos;
          _targetPos = newPos;
        });

        // Rung nhẹ mỗi lần có cập nhật vị trí mới — cảm giác "sống" hơn.
        HapticFeedback.lightImpact();

        _markerAnimController.forward(from: 0);
        _mapController.move(newPos, 15);
      });

      _socket!.on('track:arrived', (_) {
        if (!mounted) return;
        setState(() => _arrived = true);
        HapticFeedback.mediumImpact();
        _showArrivedDialog();
      });

      _socket!.connect();
    } catch (_) {
      if (mounted) setState(() => _error = 'Không thể kết nối tracking server');
    }
  }

  void _onMarkerAnimTick() {
    final t = _markerAnim.value;
    setState(() {
      _shipperPos = LatLng(
        _prevPos.latitude + (_targetPos.latitude - _prevPos.latitude) * t,
        _prevPos.longitude + (_targetPos.longitude - _prevPos.longitude) * t,
      );
    });
  }

  void _showArrivedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Đã giao hàng!'),
        content: const Text('Đơn hàng của bạn đã được giao thành công.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _shareLocation() async {
    HapticFeedback.selectionClick();
    final lat = _shipperPos.latitude.toStringAsFixed(6);
    final lng = _shipperPos.longitude.toStringAsFixed(6);
    await Share.share(
      'Theo dõi đơn hàng #${widget.orderCode} của tôi trên AgriLink.\n'
      'Vị trí shipper hiện tại: https://www.google.com/maps?q=$lat,$lng'
      '${_estimatedMinutes > 0 ? '\nDự kiến còn $_estimatedMinutes phút.' : ''}',
    );
  }

  Future<void> _callShipper() async {
    HapticFeedback.selectionClick();
    final uri = Uri(scheme: 'tel', path: _kMockShipperPhone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể mở ứng dụng gọi điện')),
      );
    }
  }

  @override
  void dispose() {
    _socket?.emit('track:leave', {'orderId': widget.orderId});
    _socket?.disconnect();
    _socket?.dispose();
    _markerAnimController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  double get _progress =>
      _totalSteps == 0 ? 0 : _stepIndex / _totalSteps;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Stack(
        children: [
          // ── Map (OpenStreetMap tile / dark tile theo theme) ────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _shipperPos,
              initialZoom: 14,
            ),
            children: [
              TileLayer(
                urlTemplate: isDark
                    ? 'https://basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png'
                    : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.agrilink.app',
              ),
              if (_routePoints.length >= 2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: List.of(_routePoints),
                      color: AppColors.primary,
                      strokeWidth: 4,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _shipperPos,
                    width: 48,
                    height: 48,
                    child: const _ShipperMarker(),
                  ),
                ],
              ),
            ],
          ),

          // ── Top bar ───────────────────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _MapButton(
                      icon: Icons.arrow_back,
                      onTap: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _TopCard(
                        connected: _connected,
                        orderCode: widget.orderCode,
                      ),
                    ),
                    const SizedBox(width: 12),
                    _MapButton(
                      icon: Icons.share_location_rounded,
                      onTap: _shareLocation,
                    ),
                    const SizedBox(width: 8),
                    _MapButton(
                      icon: Icons.my_location,
                      onTap: () => _mapController.move(_shipperPos, 15),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Bottom info card ──────────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: _error != null
                  ? _buildError()
                  : _arrived
                      ? _buildArrived()
                      : _buildTracking(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTracking() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryUltraLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.delivery_dining,
                  color: AppColors.primary, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _connected ? 'Đang giao hàng' : 'Đang kết nối...',
                    style: AppTextStyles.sectionTitle.copyWith(fontSize: 16),
                  ),
                  if (_estimatedMinutes > 0)
                    Text(
                      'Dự kiến còn $_estimatedMinutes phút',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.muted),
                    ),
                ],
              ),
            ),
            if (_estimatedMinutes > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '~$_estimatedMinutes ph',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: _progress,
            minHeight: 6,
            backgroundColor: AppColors.surfaceSoft,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Kho hàng',
                style: AppTextStyles.caption.copyWith(color: AppColors.muted)),
            Text('Nhà bạn',
                style: AppTextStyles.caption.copyWith(color: AppColors.muted)),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(height: 1),
        const SizedBox(height: 16),
        _buildShipperCard(),
      ],
    );
  }

  Widget _buildShipperCard() {
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.primaryUltraLight,
          child: const Icon(Icons.person_rounded, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_kMockShipperName,
                  style: AppTextStyles.body
                      .copyWith(fontWeight: FontWeight.w600)),
              Text('Shipper AgriLink',
                  style: AppTextStyles.caption.copyWith(color: AppColors.muted)),
            ],
          ),
        ),
        _ShipperActionButton(
          icon: Icons.phone_rounded,
          onTap: _callShipper,
        ),
        const SizedBox(width: 8),
        _ShipperActionButton(
          icon: Icons.chat_bubble_rounded,
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tính năng nhắn tin sắp ra mắt')),
          ),
        ),
      ],
    );
  }

  Widget _buildArrived() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle, color: AppColors.primary, size: 48),
        const SizedBox(height: 12),
        Text('Đã giao hàng thành công!',
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 18)),
        const SizedBox(height: 4),
        Text('#${widget.orderCode}',
            style: AppTextStyles.caption.copyWith(color: AppColors.muted)),
      ],
    );
  }

  Widget _buildError() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.wifi_off, color: AppColors.error, size: 36),
        const SizedBox(height: 8),
        Text(_error!,
            style: AppTextStyles.caption.copyWith(color: AppColors.error),
            textAlign: TextAlign.center),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () {
            setState(() => _error = null);
            _connectSocket();
          },
          child: const Text('Thử lại'),
        ),
      ],
    );
  }
}

// ── Helper widgets ────────────────────────────────────────────────────────────

class _ShipperMarker extends StatelessWidget {
  const _ShipperMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Icon(Icons.delivery_dining, color: Colors.white, size: 22),
    );
  }
}

class _MapButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MapButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: AppColors.ink),
      ),
    );
  }
}

class _ShipperActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ShipperActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryUltraLight,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
      ),
    );
  }
}

class _TopCard extends StatelessWidget {
  final bool connected;
  final String orderCode;

  const _TopCard({required this.connected, required this.orderCode});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            connected ? Icons.wifi : Icons.wifi_off,
            size: 16,
            color: connected ? AppColors.primary : AppColors.muted,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Đơn #$orderCode',
              style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

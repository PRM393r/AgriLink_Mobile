import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/auth_provider.dart';
import '../../data/services/geography_service.dart';

class ProvincePicker extends StatefulWidget {
  final String? initialProvinceId;
  final String? initialDistrictId;
  final void Function(GeographyProvince? province, GeographyDistrict? district)
      onChanged;

  const ProvincePicker({
    super.key,
    this.initialProvinceId,
    this.initialDistrictId,
    required this.onChanged,
  });

  @override
  State<ProvincePicker> createState() => _ProvincePickerState();
}

class _ProvincePickerState extends State<ProvincePicker> {
  late GeographyService _geographyService;
  List<GeographyProvince> _provinces = [];
  List<GeographyDistrict> _districts = [];

  GeographyProvince? _selectedProvince;
  GeographyDistrict? _selectedDistrict;
  bool _isLoadingProvinces = false;
  bool _isLoadingDistricts = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final apiService =
        Provider.of<AuthProvider>(context, listen: false).apiService;
    _geographyService = GeographyService(apiService);
    _loadProvinces();
  }

  Future<void> _loadProvinces() async {
    if (!mounted) return;
    setState(() {
      _isLoadingProvinces = true;
      _error = null;
    });
    try {
      final list = await _geographyService.getProvinces();
      if (!mounted) return;
      setState(() {
        _provinces = list;
        _isLoadingProvinces = false;
        if (widget.initialProvinceId != null) {
          final found = list.where((p) => p.id == widget.initialProvinceId);
          if (found.isNotEmpty) {
            _selectedProvince = found.first;
            _loadDistricts(_selectedProvince!.id);
          }
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingProvinces = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _loadDistricts(String provinceId) async {
    if (!mounted) return;
    setState(() {
      _isLoadingDistricts = true;
      _districts = [];
      _selectedDistrict = null;
    });
    try {
      final list = await _geographyService.getDistricts(provinceId);
      if (!mounted) return;
      setState(() {
        _districts = list;
        _isLoadingDistricts = false;
        if (widget.initialDistrictId != null) {
          final found = list.where((d) => d.id == widget.initialDistrictId);
          if (found.isNotEmpty) {
            _selectedDistrict = found.first;
          }
        }
        widget.onChanged(_selectedProvince, _selectedDistrict);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingDistricts = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingProvinces) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Text(
        _error!,
        style: const TextStyle(color: AppColors.error),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<GeographyProvince>(
          decoration: const InputDecoration(
            labelText: 'Tỉnh / Thành phố',
            prefixIcon: Icon(Icons.map_outlined),
          ),
          value: _selectedProvince,
          items: _provinces.map((province) {
            return DropdownMenuItem<GeographyProvince>(
              value: province,
              child: Text(province.name),
            );
          }).toList(),
          onChanged: (province) {
            setState(() {
              _selectedProvince = province;
            });
            if (province != null) {
              _loadDistricts(province.id);
            }
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<GeographyDistrict>(
          decoration: InputDecoration(
            labelText: 'Quận / Huyện',
            prefixIcon: const Icon(Icons.location_city_outlined),
            suffixIcon: _isLoadingDistricts
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: Padding(
                      padding: EdgeInsets.all(4.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
          ),
          value: _selectedDistrict,
          disabledHint: const Text('Vui lòng chọn Tỉnh/Thành phố trước'),
          items: _selectedProvince == null
              ? null
              : _districts.map((district) {
                  return DropdownMenuItem<GeographyDistrict>(
                    value: district,
                    child: Text(district.name),
                  );
                }).toList(),
          onChanged: _selectedProvince == null
              ? null
              : (district) {
                  setState(() {
                    _selectedDistrict = district;
                  });
                  widget.onChanged(_selectedProvince, district);
                },
        ),
      ],
    );
  }
}

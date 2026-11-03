import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/app_states.dart';
import '../../../shared/widgets/section_header.dart';
import '../domain/address.dart';

class AddressFormScreen extends ConsumerWidget {
  const AddressFormScreen({super.key, this.addressId});

  final String? addressId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addresses = ref.watch(addressesProvider);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: addresses.when(
          loading: () => const AppLoading(),
          error: (error, stackTrace) => AppErrorState(
            message: 'We could not load your addresses.',
            onRetry: () => ref.invalidate(addressesProvider),
          ),
          data: (items) {
            Address? existing;
            if (addressId != null) {
              for (final item in items) {
                if (item.id == addressId) existing = item;
              }
            }
            if (addressId != null && existing == null) {
              return AppErrorState(
                message: 'That address could not be found.',
                onRetry: () => context.pop(),
              );
            }
            return _AddressFormBody(
              key: ValueKey(addressId ?? 'new-address'),
              existing: existing,
            );
          },
        ),
      ),
    );
  }
}

class _AddressFormBody extends ConsumerStatefulWidget {
  const _AddressFormBody({super.key, this.existing});

  final Address? existing;

  @override
  ConsumerState<_AddressFormBody> createState() => _AddressFormBodyState();
}

class _AddressFormBodyState extends ConsumerState<_AddressFormBody> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(
    text: widget.existing?.fullName ?? '',
  );
  late final _phone = TextEditingController(text: widget.existing?.phone ?? '');
  late final _line1 = TextEditingController(text: widget.existing?.line1 ?? '');
  late final _line2 = TextEditingController(text: widget.existing?.line2 ?? '');
  late final _city = TextEditingController(text: widget.existing?.city ?? '');
  late final _state = TextEditingController(text: widget.existing?.state ?? '');
  late final _postal = TextEditingController(
    text: widget.existing?.postalCode ?? '',
  );
  late final _country = TextEditingController(
    text: widget.existing?.country ?? 'Philippines',
  );
  late bool _isDefault = widget.existing?.isDefault ?? true;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _line1.dispose();
    _line2.dispose();
    _city.dispose();
    _state.dispose();
    _postal.dispose();
    _country.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref
          .read(profileRepositoryProvider)
          .saveAddress(
            Address(
              id: widget.existing?.id ?? '',
              fullName: _name.text.trim(),
              line1: _line1.text.trim(),
              line2: _line2.text.trim().isEmpty ? null : _line2.text.trim(),
              city: _city.text.trim(),
              state: _state.text.trim(),
              postalCode: _postal.text.trim(),
              country: _country.text.trim(),
              phone: _phone.text.trim(),
              isDefault: _isDefault,
            ),
          );
      ref.invalidate(addressesProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Address saved')));
      context.pop();
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isEditing = widget.existing != null;

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(
        MediaQuery.sizeOf(context).width >= 768 ? 32 : 20,
        8,
        MediaQuery.sizeOf(context).width >= 768 ? 32 : 20,
        30,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ScreenHeader(
                  title: isEditing ? 'Edit Address' : 'Add Address',
                  padding: EdgeInsets.zero,
                  onBack: () => context.pop(),
                ),
                const SizedBox(height: 22),
                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: palette.dangerSoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _error!,
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: palette.danger),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                _Field(
                  label: 'Full Name',
                  controller: _name,
                  hint: 'Juan Dela Cruz',
                  textCapitalization: TextCapitalization.words,
                  validator: Validators.name,
                ),
                _Field(
                  label: 'Mobile Number',
                  controller: _phone,
                  hint: '+63 917 555 0147',
                  keyboardType: TextInputType.phone,
                  validator: Validators.phMobile,
                ),
                _Field(
                  label: 'House / Street',
                  controller: _line1,
                  hint: 'Unit 12, 123 Sample Street',
                  textCapitalization: TextCapitalization.words,
                  validator: (value) =>
                      Validators.required(value, label: 'House / Street'),
                ),
                _Field(
                  label: 'Barangay',
                  controller: _line2,
                  hint: 'Barangay San Lorenzo',
                  textCapitalization: TextCapitalization.words,
                  validator: (value) =>
                      Validators.required(value, label: 'Barangay'),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _Field(
                        label: 'City / Municipality',
                        controller: _city,
                        hint: 'Makati City',
                        textCapitalization: TextCapitalization.words,
                        validator: (value) => Validators.required(
                          value,
                          label: 'City / Municipality',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: _Field(
                        label: 'Postal Code',
                        controller: _postal,
                        hint: '1223',
                        keyboardType: TextInputType.number,
                        validator: Validators.postalCode,
                      ),
                    ),
                  ],
                ),
                _Field(
                  label: 'Province',
                  controller: _state,
                  hint: 'Metro Manila',
                  textCapitalization: TextCapitalization.words,
                  validator: (value) =>
                      Validators.required(value, label: 'Province'),
                ),
                _Field(
                  label: 'Country',
                  controller: _country,
                  hint: 'Philippines',
                  readOnly: true,
                ),
                const SizedBox(height: 4),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Set As Default Address'),
                  subtitle: const Text('Use this address first at checkout'),
                  value: _isDefault,
                  onChanged: widget.existing?.isDefault == true
                      ? null
                      : (value) => setState(() => _isDefault = value),
                ),
                if (widget.existing?.isDefault == true)
                  Text(
                    'Choose another address as default to change this setting.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(isEditing ? 'Save Changes' : 'Add Address'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
    this.readOnly = false,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            textCapitalization: textCapitalization,
            validator: validator,
            readOnly: readOnly,
            decoration: InputDecoration(hintText: hint),
          ),
        ],
      ),
    );
  }
}

class AddressItem {
  final String id;
  final String label;
  final String recipientName;
  final String phoneNumber;
  final String fullAddress;
  final bool isDefault;

  AddressItem({
    required this.id,
    required this.label,
    required this.recipientName,
    required this.phoneNumber,
    required this.fullAddress,
    required this.isDefault,
  });
}
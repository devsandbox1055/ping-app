class PartnerStatus {
  final int partnerId;
  final String status;
  final DateTime? lastSeen;

  PartnerStatus({required this.partnerId, required this.status, this.lastSeen});

  factory PartnerStatus.fromJson(Map<String, dynamic> json) {
    return PartnerStatus(
      partnerId: json['partner_id'],
      status: json['status'],
      lastSeen: json['last_seen'] != null
          ? DateTime.parse(json['last_seen'])
          : null,
    );
  }

  
  PartnerStatus copyWith({int? partnerId, String? status, DateTime? lastSeen}) {
    return PartnerStatus(
      partnerId: partnerId ?? this.partnerId,
      status: status ?? this.status,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }

  bool get isOnline => status == 'online';
  bool get isAway => status == 'away';
  String get statusText {
    switch (status) {
      case 'online':
        return 'Online';
      case 'away':
        return 'Away';
      default:
        return 'Offline';
    }
  }
}

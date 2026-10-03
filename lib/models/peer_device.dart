enum PeerAvailability { available, busy, offline }

class PeerDevice {
  const PeerDevice({
    required this.id,
    required this.name,
    required this.availability,
  });

  final String id;
  final String name;
  final PeerAvailability availability;
}

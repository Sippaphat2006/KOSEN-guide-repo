class Facility {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final String? hours;
  final String? contact;
  final String? description;

  const Facility({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    this.hours,
    this.contact,
    this.description,
  });

  factory Facility.fromJson(Map<String, dynamic> j) => Facility(
        id: j['id'],
        name: j['name'],
        lat: (j['lat'] as num).toDouble(),
        lng: (j['lng'] as num).toDouble(),
        hours: j['hours'],
        contact: j['contact'],
        description: j['description'],
      );
}

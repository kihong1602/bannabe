import '../models/station.dart';

class StationRepository {
  static final StationRepository _instance = StationRepository._internal();
  static StationRepository get instance => _instance;

  StationRepository._internal();

  Future<List<Station>> getNearbyStations() async {
    // TODO: 실제 API 연동
    await Future.delayed(const Duration(seconds: 1));
    return [
      Station(
        id: 'S1',
        name: '강남역점',
        address: '서울특별시 강남구 강남대로 396',
        latitude: 37.498095,
        longitude: 127.027610,
        isActive: true,
      ),
      Station(
        id: 'S2',
        name: '홍대입구역점',
        address: '서울특별시 마포구 양화로 160',
        latitude: 37.557192,
        longitude: 126.924618,
        isActive: true,
      ),
      Station(
        id: 'S3',
        name: '명동점',
        address: '서울특별시 중구 명동길 74',
        latitude: 37.563740,
        longitude: 126.983024,
        isActive: true,
      ),
      Station(
        id: 'S4',
        name: '여의도역점',
        address: '서울특별시 영등포구 여의나루로 42',
        latitude: 37.521564,
        longitude: 126.924618,
        isActive: true,
      ),
    ];
  }

  Future<Station?> getStation(String id) async {
    final stations = await getNearbyStations();
    return stations.firstWhere(
      (station) => station.id == id,
      orElse: () => throw Exception('Station not found'),
    );
  }
}

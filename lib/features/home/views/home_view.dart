import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/home_viewmodel.dart';
import '../../../core/widgets/bottom_navigation_bar.dart';
import '../../../core/widgets/loading_animation.dart';
import '../../../app/routes.dart';
import '../../../core/constants/app_colors.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(),
      child: Column(
        children: [
          Expanded(
            child: Scaffold(
              appBar: AppBar(
                title: const Text('Bannabee'),
                centerTitle: true,
                automaticallyImplyLeading: false,
              ),
              body: SafeArea(
                child: Consumer<HomeViewModel>(
                  builder: (context, viewModel, child) {
                    if (!viewModel.hasLocationPermission) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              '위치 권한이 필요합니다',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '주변 스테이션을 찾기 위해\n위치 권한이 필요합니다.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              child: const Text('위치 권한 허용'),
                              onPressed: () async {
                                final hasPermission =
                                    await viewModel.requestLocationPermission();
                                if (!hasPermission) {
                                  if (context.mounted) {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('위치 권한 필요'),
                                        content: const Text(
                                          '주변 스테이션을 찾기 위해 위치 권한이 필요합니다.\n설정에서 위치 권한을 허용해주세요.',
                                        ),
                                        actions: [
                                          TextButton(
                                            child: const Text('취소'),
                                            onPressed: () =>
                                                Navigator.pop(context),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              // TODO: 시스템 설정으로 이동
                                            },
                                            child: const Text('설정으로 이동'),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    }

                    if (viewModel.isLoading) {
                      return const Center(
                        child: HoneyLoadingAnimation(
                          isStationSelected: false,
                        ),
                      );
                    }

                    if (viewModel.error != null) {
                      return Center(child: Text(viewModel.error!));
                    }

                    return RefreshIndicator(
                      onRefresh: viewModel.refresh,
                      child: CustomScrollView(
                        slivers: [
                          const SliverPadding(
                            padding: EdgeInsets.only(top: 8),
                          ),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: DefaultTextStyle.merge(
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.blue,
                                ),
                                child: Column(
                                  children: [
                                    _buildSearchBar(),
                                    const SizedBox(height: 16),
                                    _buildNoticeSection(context, viewModel),
                                    const SizedBox(height: 16),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pushNamed(Routes.map);
                                      },
                                      icon: const Icon(Icons.map),
                                      label: const Text('지도에서 스테이션 찾기'),
                                      style: ElevatedButton.styleFrom(
                                        minimumSize:
                                            const Size(double.infinity, 48),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SliverList(
                            delegate: SliverChildListDelegate([
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context)
                                        .pushNamed(Routes.rentalStatus);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              '현재 대여 중',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.refresh),
                                              onPressed: viewModel.refresh,
                                            ),
                                          ],
                                        ),
                                        if (viewModel.activeRentals.isEmpty)
                                          const Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 16.0,
                                            ),
                                            child: Text('현재 대여 중인 물품이 없습니다.'),
                                          )
                                        else
                                          ...viewModel.activeRentals.map(
                                            (rental) => Padding(
                                              padding: const EdgeInsets.only(
                                                top: 16.0,
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    rental.accessoryName,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    '남은 시간: ${rental.remainingTime.inHours}시간 ${rental.remainingTime.inMinutes % 60}분',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ]),
                          ),
                          _buildRecentRentals(viewModel),
                          SliverToBoxAdapter(
                            child: Container(
                              height: 8,
                              color: Colors.grey[200],
                            ),
                          ),
                          _buildNearbyStations(context, viewModel),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const AppBottomNavigationBar(currentIndex: 0),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return InkWell(
      onTap: () {
        // TODO: 검색 화면으로 이동
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.search,
              color: Colors.grey[600],
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              '검색',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoticeSection(BuildContext context, HomeViewModel viewModel) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(Routes.noticeList);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.info_outline,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                viewModel.latestNotice?.title ?? '새로운 공지사항이 없습니다.',
                style: const TextStyle(fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[600],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentRentals(HomeViewModel viewModel) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              '최근 대여 내역',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (viewModel.recentRentals.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('최근 대여 내역이 없습니다.'),
            )
          else
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: viewModel.recentRentals.length,
                itemBuilder: (context, index) {
                  final rental = viewModel.recentRentals[index];
                  return Container(
                    width: 200,
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                rental.accessoryName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                rental.stationName,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Colors.grey[300]!),
                            ),
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed(
                                Routes.rental,
                                arguments: {
                                  'accessoryId': rental.accessoryId,
                                  'stationId': rental.stationId,
                                },
                              );
                            },
                            child: const Text('대여하기'),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildNearbyStations(BuildContext context, HomeViewModel viewModel) {
    return SliverList(
      delegate: SliverChildListDelegate([
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            '주변 스테이션',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (viewModel.nearbyStations.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('주변에 스테이션이 없습니다.'),
          )
        else
          ...viewModel.nearbyStations.map((station) => InkWell(
                onTap: () {
                  Navigator.of(context).pushNamed(
                    Routes.rental,
                    arguments: station,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey[300]!,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        station.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        station.address,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              )),
      ]),
    );
  }
}

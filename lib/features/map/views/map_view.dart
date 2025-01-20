import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_theme.dart';
import '../viewmodels/map_viewmodel.dart';
import '../../../app/routes.dart';

class MapView extends StatelessWidget {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MapViewModel()..init(),
      child: const _MapContent(),
    );
  }
}

class _MapContent extends StatelessWidget {
  const _MapContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('주변 스테이션'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Consumer<MapViewModel>(
          builder: (context, viewModel, _) {
            if (viewModel.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (viewModel.error != null) {
              return Center(
                child: Text(
                  viewModel.error!,
                  style: AppTheme.bodyMedium,
                ),
              );
            }

            return Stack(
              children: [
                NaverMap(
                  onMapReady: (controller) {
                    viewModel.onMapCreated(controller);
                  },
                  options: NaverMapViewOptions(
                    initialCameraPosition: NCameraPosition(
                      target: NLatLng(
                        viewModel.currentLocation?.latitude ?? 37.5665,
                        viewModel.currentLocation?.longitude ?? 126.9780,
                      ),
                      zoom: 15,
                    ),
                    contentPadding: const EdgeInsets.all(0),
                  ),
                  onMapTapped: (point, latLng) {
                    viewModel.clearSelectedStation();
                  },
                ),
                Positioned(
                  right: 16,
                  bottom: viewModel.selectedStation != null ? 200 : 16,
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: AppColors.white,
                    child: const Icon(
                      Icons.my_location,
                      color: AppColors.black,
                    ),
                    onPressed: viewModel.refreshLocation,
                  ),
                ),
                if (viewModel.selectedStation != null)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    viewModel.selectedStation!.name,
                                    style: AppTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    viewModel.selectedStation!.address,
                                    style: AppTheme.bodyMedium.copyWith(
                                      color: AppColors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(
                                  Icons.close,
                                  color: AppColors.grey,
                                ),
                                onPressed: viewModel.clearSelectedStation,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.black,
                              ),
                              child: const Text('이 스테이션에서 대여하기'),
                              onPressed: () {
                                Navigator.of(context).pushNamed(
                                  Routes.rental,
                                  arguments: viewModel.selectedStation,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

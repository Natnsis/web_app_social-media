import 'dart:async';
import 'dart:ui' as ui;

import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/discovery/domain/entities/nearby_churches_meta.dart';
import 'package:faithconnect/features/discovery/domain/entities/discovery_nearby_church.dart';
import 'package:faithconnect/core/utils/marker_icon_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_cluster_manager_2/google_maps_cluster_manager_2.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' hide ClusterManager, Cluster;

class ChurchClusterItem with ClusterItem {
  final DiscoveryNearbyChurch church;

  ChurchClusterItem(this.church);

  @override
  LatLng get location => LatLng(church.latitude!, church.longitude!);
}

class NearbyChurchesMap extends StatefulWidget {
  final List<DiscoveryNearbyChurch> churches;
  final NearbyChurchesMeta? meta;
  final Function(String) onChurchTap;
  final double bottomPadding;

  const NearbyChurchesMap({
    super.key,
    required this.churches,
    this.meta,
    required this.onChurchTap,
    this.bottomPadding = 0.0,
  });

  @override
  State<NearbyChurchesMap> createState() => _NearbyChurchesMapState();
}

class _NearbyChurchesMapState extends State<NearbyChurchesMap> {
  late ClusterManager _manager;
  final Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};
  
  // Cache for church logo markers
  final Map<String, BitmapDescriptor> _markerCache = {};

  @override
  void initState() {
    super.initState();
    _manager = _initClusterManager();
    _loadMarkerIcons();
  }

  @override
  void didUpdateWidget(NearbyChurchesMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.churches != widget.churches) {
      _manager.setItems(widget.churches
          .where((c) => c.isActive && c.latitude != null && c.longitude != null)
          .map((c) => ChurchClusterItem(c))
          .toList());
      _loadMarkerIcons();
      _fitBounds();
    }
  }

  ClusterManager _initClusterManager() {
    final items = widget.churches
        .where((c) => c.isActive && c.latitude != null && c.longitude != null)
        .map((c) => ChurchClusterItem(c))
        .toList();

    return ClusterManager<ChurchClusterItem>(
      items,
      _updateMarkers,
      markerBuilder: _markerBuilder,
      levels: const [1, 4.25, 6.75, 8.25, 11.5, 14.5, 16.0, 16.5, 20.0],
    );
  }

  void _updateMarkers(Set<Marker> markers) {
    if (!mounted) return;
    setState(() {
      _markers = markers;
    });
  }

  Future<void> _loadMarkerIcons() async {
    final futures = <Future<void>>[];
    bool hasNewMarkers = false;

    for (var church in widget.churches) {
      if (church.isActive &&
          church.latitude != null &&
          church.longitude != null &&
          !_markerCache.containsKey(church.id)) {
        
        futures.add(() async {
          final marker = await MarkerIconGenerator.getChurchMarker(
            church.name,
            church.logoUrl ?? church.avatarUrl ?? church.imageUrl,
          );
          _markerCache[church.id] = marker;
          hasNewMarkers = true;
        }());
      }
    }

    if (futures.isNotEmpty) {
      await Future.wait(futures);
      if (mounted && hasNewMarkers) {
        setState(() {});
        _manager.updateMap();
      }
    }
  }

  Future<Marker> _markerBuilder(dynamic clusterParam) async {
    final cluster = clusterParam as Cluster<ChurchClusterItem>;
    
    final church = cluster.items.first.church;
    BitmapDescriptor icon = _markerCache[church.id] ?? 
           await MarkerIconGenerator.getChurchMarker(
             church.name, 
             church.logoUrl ?? church.avatarUrl ?? church.imageUrl,
           );
    _markerCache[church.id] = icon; // Cache it for next time

    return Marker(
      markerId: MarkerId(cluster.getId()),
      position: cluster.location,
      anchor: const Offset(0.5, 1.0),
      onTap: () {
        if (cluster.isMultiple) {
          _zoomToCluster(cluster);
        } else {
          _showChurchBottomSheet(cluster.items.first.church);
        }
      },
      icon: icon,
    );
  }

  Future<BitmapDescriptor> _getClusterMarker(int clusterSize) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    const size = 150;
    final width = size.toDouble();
    final height = size.toDouble();

    final center = Offset(width / 2, height / 2 - 15);
    final circleRadius = width / 2 - 15;
    final point = Offset(width / 2, height - 5);

    // Draw shadow under the pin
    final shadowPath = Path()
      ..addOval(Rect.fromCenter(
        center: Offset(width / 2, height - 5),
        width: 50,
        height: 15,
      ));
    canvas.drawPath(
      shadowPath,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    // Draw pin path (circle + triangle pointer)
    final pinPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: circleRadius))
      ..moveTo(center.dx - 22, center.dy + 20)
      ..lineTo(point.dx, point.dy)
      ..lineTo(center.dx + 22, center.dy + 20)
      ..close();

    // Draw white pin background
    canvas.drawPath(pinPath, Paint()..color = Colors.white);

    // Draw inner blue circle
    final innerRadius = circleRadius - 6;
    final bgPaint = Paint()..color = const Color(0xFF3366FF); // Brand blue
    canvas.drawCircle(center, innerRadius, bgPaint);

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: clusterSize.toString(),
      style: TextStyle(
        fontSize: innerRadius * 0.8,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - (textPainter.width / 2),
        center.dy - (textPainter.height / 2),
      ),
    );

    final img = await pictureRecorder.endRecording().toImage(size, size);
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }

  Future<void> _zoomToCluster(Cluster<ChurchClusterItem> cluster) async {
    final controller = await _controller.future;
    final currentZoom = await controller.getZoomLevel();
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: cluster.location, zoom: currentZoom + 2),
      ),
    );
  }

  Future<void> _fitBounds() async {
    final controller = await _controller.future;
    final activeChurches = widget.churches
        .where((c) => c.isActive && c.latitude != null && c.longitude != null)
        .toList();

    if (activeChurches.isEmpty) return;

    if (activeChurches.length == 1) {
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(activeChurches.first.latitude!, activeChurches.first.longitude!),
          14.0,
        ),
      );
      return;
    }

    double minLat = activeChurches.first.latitude!;
    double maxLat = activeChurches.first.latitude!;
    double minLng = activeChurches.first.longitude!;
    double maxLng = activeChurches.first.longitude!;

    for (var c in activeChurches) {
      if (c.latitude! < minLat) minLat = c.latitude!;
      if (c.latitude! > maxLat) maxLat = c.latitude!;
      if (c.longitude! < minLng) minLng = c.longitude!;
      if (c.longitude! > maxLng) maxLng = c.longitude!;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  void _showChurchBottomSheet(DiscoveryNearbyChurch church) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final colors = context.faithColors;
        return Container(
          decoration: BoxDecoration(
            color: colors.scaffoldBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (church.coverImageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                  child: Image.network(
                    church.coverImageUrl!,
                    height: 100.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 100.h,
                      width: double.infinity,
                      color: colors.brandBlue.withValues(alpha: 0.2),
                      child: Icon(Icons.church, size: 48.r, color: colors.brandBlue),
                    ),
                  ),
                ),
              Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            church.name,
                            style: GoogleFonts.inter(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w700,
                              color: colors.primaryText,
                            ),
                          ),
                        ),
                        if (church.verificationStatus == 'APPROVED') ...[
                          SizedBox(width: 8.w),
                          Icon(Icons.verified, color: colors.brandBlue, size: 20.r),
                        ],
                      ],
                    ),
                    SizedBox(height: 8.h),
                    if (church.address != null && church.address!.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(Icons.location_on, color: colors.mutedText, size: 16.r),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              '\${church.address}',
                              style: GoogleFonts.inter(
                                fontSize: 13.sp,
                                color: colors.mutedText,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                    ],
                    Row(
                      children: [
                        Icon(Icons.people, color: colors.mutedText, size: 16.r),
                        SizedBox(width: 4.w),
                        Text(
                          '\${church.followerCount} followers',
                          style: GoogleFonts.inter(
                            fontSize: 13.sp,
                            color: colors.mutedText,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        if (church.distanceKm != null) ...[
                          Icon(Icons.directions_walk, color: colors.mutedText, size: 16.r),
                          SizedBox(width: 4.w),
                          Text(
                            '\${church.distanceKm!.toStringAsFixed(1)} km away',
                            style: GoogleFonts.inter(
                              fontSize: 13.sp,
                              color: colors.mutedText,
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      church.description ?? '',
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        color: colors.primaryText,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: PrimaryButton(
                            text: 'View Profile',
                            onPressed: () {
                              Navigator.pop(context);
                              widget.onChurchTap(church.id);
                            },
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: PrimaryButton(
                            text: church.isFollowing ? 'Following' : 'Follow',
                            onPressed: () {
                              // Let the parent or bloc handle the actual follow logic
                              // Here we just preview the UI
                            },
                            backgroundColor: church.isFollowing ? colors.brandBlue.withValues(alpha: 0.1) : colors.brandBlue,
                            textColor: church.isFollowing ? colors.brandBlue : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    
    return GoogleMap(
      padding: EdgeInsets.only(bottom: widget.bottomPadding),
      mapType: MapType.normal,
      initialCameraPosition: CameraPosition(
        target: widget.meta?.center != null
            ? LatLng(widget.meta!.center!.latitude, widget.meta!.center!.longitude)
            : const LatLng(9.03, 38.74), // Default to Addis Ababa
        zoom: 12.0,
      ),
      markers: _markers,
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
        _manager.setMapId(controller.mapId);
        
        // Optional: Set map style for dark mode
        if (isDark) {
          // You could load a dark style JSON here
        }
        
        // Wait a bit for map to initialize then fit bounds
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) _fitBounds();
        });
      },
      onCameraMove: _manager.onCameraMove,
      onCameraIdle: _manager.updateMap,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
    );
  }
}

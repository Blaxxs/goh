// lib/core/constants/accessory_precache_extension.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'accessory_constants.dart';
import 'package:flutter/foundation.dart';

/// Extension to precache all accessory images
extension AccessoryPrecache on AccessoryDataManager {
  /// Precaches all accessory images for faster display.
  /// Uses CachedNetworkImage's cache manager for proper disk caching.
  /// This should be called during app startup (LoadingScreen) for optimal UX.
  Future<void> precacheAllImages(BuildContext context) async {
    if (allAccessories.isEmpty) {
      if (kDebugMode) {
        debugPrint('[AccessoryDataManager] No accessories to precache.');
      }
      return;
    }
    
    try {
      final cacheManager = DefaultCacheManager();
      List<Future<void>> cacheFutures = [];
      int totalImagesToCache = 0;
.\deploy.bat
      
      for (var accessory in allAccessories) {
        // Precache main accessory image
        totalImagesToCache++;
        cacheFutures.add(
          cacheManager.getSingleFile(accessory.imageUrl)
              .then((_) => null)
              .catchError((e) {
            if (kDebugMode) {
              debugPrint('[AccessoryDataManager] Failed to cache ${accessory.name}: $e');
            }
          }),
        );
        
        // Precache set option accessory images
        for (var setOption in accessory.setOptions) {
          for (var imageUrl in setOption.requiredAccessoryImages) {
            totalImagesToCache++;
            cacheFutures.add(
              cacheManager.getSingleFile(imageUrl)
                  .then((_) => null)
                  .catchError((e) {
                if (kDebugMode) {
                  debugPrint('[AccessoryDataManager] Failed to cache set image: $e');
                }
              }),
            );
          }
        }
      }
      
      if (kDebugMode) {
        debugPrint('[AccessoryDataManager] Caching $totalImagesToCache images to disk...');
      }
      
      await Future.wait(cacheFutures);
      
      if (kDebugMode) {
        debugPrint('[AccessoryDataManager] Successfully cached all accessory images to disk');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AccessoryDataManager] Error caching images: $e');
      }
    }
  }
}

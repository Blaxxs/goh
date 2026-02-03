// lib/core/constants/accessory_precache_extension.dart
import 'package:flutter/material.dart';
import 'accessory_constants.dart';
import 'package:flutter/foundation.dart';

/// Extension to precache all accessory images
extension AccessoryPrecache on AccessoryDataManager {
  /// Precaches all accessory images for faster display.
  /// This should be called during app startup (LoadingScreen) for optimal UX.
  Future<void> precacheAllImages(BuildContext context) async {
    if (allAccessories.isEmpty) {
      if (kDebugMode) {
        debugPrint('[AccessoryDataManager] No accessories to precache.');
      }
      return;
    }
    
    try {
      List<Future<void>> cacheFutures = [];
      
      for (var accessory in allAccessories) {
        // Precache main accessory image
        cacheFutures.add(
          precacheImage(NetworkImage(accessory.imageUrl), context)
              .catchError((e) {
            if (kDebugMode) {
              debugPrint('[AccessoryDataManager] Failed to precache ${accessory.name}: $e');
            }
          }),
        );
        
        // Precache set option accessory images
        for (var setOption in accessory.setOptions) {
          for (var imageUrl in setOption.requiredAccessoryImages) {
            cacheFutures.add(
              precacheImage(NetworkImage(imageUrl), context)
                  .catchError((e) {
                if (kDebugMode) {
                  debugPrint('[AccessoryDataManager] Failed to precache set image: $e');
                }
              }),
            );
          }
        }
      }
      
      await Future.wait(cacheFutures);
      
      if (kDebugMode) {
        debugPrint('[AccessoryDataManager] Successfully precached all accessory images');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AccessoryDataManager] Error precaching images: $e');
      }
    }
  }
}

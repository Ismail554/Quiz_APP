import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geography_geyser/core/app_logger.dart';
import 'package:geography_geyser/models/select_time_model.dart';
import 'package:geography_geyser/services/api_service.dart';
import 'package:geography_geyser/services/https_service.dart';

class SelectTimeProvider extends ChangeNotifier {
  bool isLoading = false;
  List<SelectTimeModel> timeList = [];

  Future<void> fetchSelectTimes() async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await HttpManager.apiRequest(
        url: ApiService.timeListUrl,
        method: Method.get,
        name: 'SelectTimes',
        statusCode: 200,
      );

      response.fold(
        (error) {
          AppLogger.error('Failed to fetch select times: $error');
        },
        (data) {
          final decodedData = json.decode(data);
          final parsed = SelectTimeResponse.fromJson(decodedData);
          timeList = parsed.results;
          // Sort the timeList by duration in ascending order
          timeList.sort((a, b) => a.duration.compareTo(b.duration));
        },
      );
    } catch (e) {
      AppLogger.error('Error fetching select times', e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

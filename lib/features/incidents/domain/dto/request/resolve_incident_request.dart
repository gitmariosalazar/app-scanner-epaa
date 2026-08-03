import 'dart:io';

import 'package:equatable/equatable.dart';

class ResolveIncidentRequest extends Equatable {
  final String description;
  final double repairCost;
  final bool chargeToUser;
  final List<File> images;

  const ResolveIncidentRequest({
    required this.description,
    required this.repairCost,
    required this.chargeToUser,
    required this.images,
  });

  @override
  List<Object?> get props => [description, repairCost, chargeToUser, images];

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'repairCost': repairCost,
      'chargeToUser': chargeToUser,
      'images': images,
    };
  }
}

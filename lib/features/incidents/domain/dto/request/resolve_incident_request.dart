import 'package:equatable/equatable.dart';

class ResolveIncidentRequest extends Equatable {
  final String description;
  final double repairCost;
  final bool chargeToUser;
  final List<String>? images;

  const ResolveIncidentRequest({
    required this.description,
    required this.repairCost,
    required this.chargeToUser,
    this.images,
  });

  @override
  List<Object?> get props => [description, repairCost, chargeToUser, images];

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'repairCost': repairCost,
      'chargeToUser': chargeToUser,
      if (images != null) 'images': images,
    };
  }
}

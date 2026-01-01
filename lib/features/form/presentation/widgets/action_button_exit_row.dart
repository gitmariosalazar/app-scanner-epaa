import 'package:flutter/material.dart';
import 'package:flutter_application/components/button/widget_button.dart';
import 'package:flutter_application/core/di/injection.dart';
import 'package:flutter_application/features/work-orders/presentation/blocs/create_work_order/create_work_order_bloc.dart';
import 'package:flutter_application/features/work-orders/presentation/widgets/add_work_order_form.dart';
import 'package:flutter_application/utils/responsive_utils.dart';
import 'package:flutter_application/utils/screen_type_layout.dart';
import 'package:go_router/go_router.dart';

class AppColors {
  static const primary = Color(0xFF0288D1);
  static const error = Color(0xFFE57373);
}

class ActionButtonExitRow extends StatelessWidget {
  final Map<String, String> prefillData;
  final AnimationController animationController;
  final Animation<double> scaleAnimation;

  const ActionButtonExitRow({
    super.key,
    required this.prefillData,
    required this.animationController,
    required this.scaleAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveRow(
      forceRow: true,
      rowSpacing: ResponsiveUtils.largeSpacing(context),
      children: [
        ResponsiveButton(
          onPressed: () => context.go('/home'), // Siempre funciona
          icon: Icons.cancel,
          label: 'Cancelar',
          color: AppColors.error,
          loading: false,
          height: ResponsiveUtils.buttonSmall(context),
          animationController: animationController,
          scaleAnimation: scaleAnimation,
        ),
        ResponsiveButton(
          onPressed: () async {
            final bloc = sl<CreateWorkOrderBloc>();

            await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => AddWorkOrderResponsiveDialog(
                prefillData: prefillData,
                bloc: bloc,
              ),
            );

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Orden de trabajo creada con éxito"),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );
          },
          icon: Icons.work_outline,
          label: 'O. Trabajo',
          color: AppColors.primary,
          loading: false,
          height: ResponsiveUtils.buttonSmall(context),
          animationController: animationController,
          scaleAnimation: scaleAnimation,
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_application/components/button/widget_button.dart';
import 'package:flutter_application/utils/responsive_utils.dart';
import 'package:flutter_application/utils/screen_type_layout.dart';
import 'package:flutter_application/features/form/presentation/blocs/readings/form_bloc.dart'
    as form_bloc;
import 'package:go_router/go_router.dart';

class AppColors {
  static const primary = Color(0xFF0288D1);
  static const secondary = Color(0xFF4CAF50);
  static const error = Color(0xFFE57373);
}

class ActionButtonsRow extends StatelessWidget {
  final form_bloc.FormState state;
  final VoidCallback onSavePressed;
  final Map<String, String> prefillData;
  final AnimationController animationController;
  final Animation<double> scaleAnimation;

  const ActionButtonsRow({
    super.key,
    required this.state,
    required this.onSavePressed,
    required this.prefillData,
    required this.animationController,
    required this.scaleAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLoading = state is form_bloc.FormLoading;

    return ResponsiveRow(
      forceRow: true,
      rowSpacing: ResponsiveUtils.largeSpacing(context),
      children: [
        ResponsiveButton(
          onPressed: isLoading ? null : onSavePressed,
          icon: Icons.save,
          label: 'Guardar',
          color: AppColors.secondary,
          loading: isLoading,
          height: ResponsiveUtils.buttonSmall(context),
          animationController: animationController,
          scaleAnimation: scaleAnimation,
        ),
        ResponsiveButton(
          onPressed: () => context.go('/home'), // Siempre habilitado
          icon: Icons.cancel,
          label: 'Cancelar',
          color: AppColors.error,
          loading: false, // Nunca muestra loading
          height: ResponsiveUtils.buttonSmall(context),
          animationController: animationController,
          scaleAnimation: scaleAnimation,
        ),
        ResponsiveButton(
          onPressed: () async {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Funcionalidad en desarrollo, próximamente..."),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 3),
              ),
            );
            /*
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
            */
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

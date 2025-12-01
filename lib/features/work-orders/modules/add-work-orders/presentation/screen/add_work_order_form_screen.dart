import 'package:flutter/material.dart';
import 'package:flutter_application/features/work-orders/modules/add-work-orders/presentation/widgets/add_work_order_form.dart';

class AddWorkOrderFormScreen extends StatelessWidget {
  const AddWorkOrderFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Crear Orden")),
      body: Column(
        children: [
          const Text("Formulario de orden"),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

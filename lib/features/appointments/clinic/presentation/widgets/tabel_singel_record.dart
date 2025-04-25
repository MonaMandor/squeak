
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:squeak/core/helper/build_service/main_cubit/main_cubit.dart';

class TableSingleRecord extends StatelessWidget {
  const TableSingleRecord({
    super.key,
    required this.tableRecordName,
  });

  final String tableRecordName;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MainCubit, MainState>(
      listener: (context, state) {
        // TODO: implement listener
      },
      builder: (context, state) {
        var mainCubit = BlocProvider.of<MainCubit>(context);

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Text(
              tableRecordName,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: mainCubit.isDark ? Colors.black : Colors.black),
            ),
          ),
        );
      },
    );
  }
}

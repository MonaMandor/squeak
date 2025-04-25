import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconly/iconly.dart';
import 'package:lottie/lottie.dart';
import 'package:squeak/core/thames/styles.dart';
import 'package:squeak/features/appointments/user/data/datasources/user_data_sourse.dart';
import 'package:squeak/features/appointments/user/data/repositories/user_reop.dart';
import 'package:squeak/features/appointments/user/presentation/pages/all_apointment.dart';
import 'package:squeak/features/appointments/user/presentation/widgets/filter_component.dart';
import 'package:squeak/features/layout/controller/layout_cubit.dart';
import 'package:squeak/features/appointments/user/presentation/widgets/build_item_widget.dart';
import '../../../../../core/constant/global_function/global_function.dart';
import '../../../../../generated/l10n.dart';
import '../../../../pets/models/pet_model.dart';
import '../cubit/user_appointment_cubit.dart';

class GetUserAppointment extends StatelessWidget {
  const GetUserAppointment({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserAppointmentCubit(
        UsertRepoImpl(
          UsertRemoteDataSource(),
        ),
      )
        ..getSupplier()
        ..getAppointment(true),
      child: BlocConsumer<UserAppointmentCubit, UserAppointmentState>(
        listener: (context, state) {
          if (state is DeleteAppointmentSuccess) {
            UserAppointmentCubit.get(context).getAppointment(true);
          }
          if (state is EditAppointment) {
            UserAppointmentCubit.get(context).deleteAppointments(
              state.model,
            );
          }
        },
        builder: (context, state) {
          var cubit = UserAppointmentCubit.get(context);
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: Text(S.of(context).yourAppointments),
              actions: [
                if (cubit.appointmentsCount > 0)
                  IconButton(
                    onPressed: () {
                      navigateToScreen(context, AllAppointment());
                    },
                    icon: const Icon(
                      IconlyLight.calendar,
                    ),
                  ),
              ],
            ),
            body: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: BlocConsumer<LayoutCubit, LayoutState>(
                        builder: (context, state) {
                          List<PetsData> pets = LayoutCubit.get(context).pets;
                          return buildPetFilter(context, pets);
                        },
                        listener: (context, state) {},
                      ),
                    ),
                    Expanded(
                      child: BlocConsumer<LayoutCubit, LayoutState>(
                        builder: (context, state) {
                          return buildStateFilter(context);
                        },
                        listener: (context, state) {},
                      ),
                    ),
                    if (state is AppointmentFiltered)
                      IconButton(
                        icon: Icon(Icons.clear), // Clear icon
                        onPressed: () {
                          UserAppointmentCubit.get(context).clearFilters();
                        },
                      ),
                  ],
                ),
                Expanded(
                  child: cubit.appointments.isEmpty
                      ? emptyAppointment(context)
                      : (state is AppointmentFiltered)
                          ? ListView.builder(
                              itemBuilder: (context, index) {
                                return BuildItem(
                                  appointments: state.appointments[index],
                                  context: context,
                                  cubit: cubit,
                                  index: index,
                                );
                              },
                              itemCount: state.appointments.length,
                              physics: const BouncingScrollPhysics(),
                            )
                          : RefreshIndicator(
                              onRefresh: () async {
                                await UserAppointmentCubit.get(context)
                                    .getAppointment(false);
                              },
                              child: ListView.builder(
                                itemBuilder: (context, index) {
                                  return BuildItem(
                                    appointments: cubit.appointments[index],
                                    cubit: cubit,
                                    index: index,
                                    context: context,
                                    
                                  );
                                },
                                itemCount: cubit.appointments.length,
                                physics: const BouncingScrollPhysics(),
                              ),
                            ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: ColorTheme.primaryColor,
              onPressed: () {
                LayoutCubit.get(context).changeBottomNav(1);
              },
              child: const Icon(
                IconlyLight.calendar,
                color: Colors.white,
              ),
            ),
          );
        },
      ),
    );
  }
 Center emptyAppointment(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LottieBuilder.network(
              'https://lottie.host/812196ca-692a-4bd1-8920-3bbffa763c4e/P24Orl2mFH.json',
              height: 300,
              repeat: false,
              width: double.infinity,
            ),
            InkWell(
              onTap: () {
                LayoutCubit.get(context).changeBottomNav(1);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  isArabic()
                      ? 'اختر العيادة الخاص بك واحجز موعدك.'
                      : 'Pick your Clinic and book your appointment.',
                  textAlign: TextAlign.center,
                  style: FontStyleThame.textStyle(
                    context: context,
                    fontColor: ColorTheme.secondColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

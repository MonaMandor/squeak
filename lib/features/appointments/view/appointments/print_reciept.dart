import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:squeak/core/constant/global_function/global_function.dart';
import 'package:squeak/core/helper/build_service/main_cubit/main_cubit.dart';
import 'package:squeak/core/thames/styles.dart';
import '../../../../core/helper/remotely/config_model.dart';
import '../../../../core/thames/color_manager.dart';
import '../../../../generated/l10n.dart';
import '../../controller/user/user_appointment_cubit.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PrintScreen extends StatelessWidget {
  final String id;
  String clinicPhone;
  final String clinicImage;
  final GlobalKey _globalKey = GlobalKey();

  PrintScreen({
    super.key,
    required this.id,
    required this.clinicPhone,
    required this.clinicImage,
  }) : super();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserAppointmentCubit()..getInvoives(id),
      child: BlocConsumer<UserAppointmentCubit, UserAppointmentState>(
        listener: (context, state) {
          // TODO: implement listener
        },
        builder: (context, state) {
          var cubit = UserAppointmentCubit.get(context);
          return Scaffold(
            appBar: AppBar(
              title: Text(
                isArabic() ? "الفاتورة" : 'Invoice',
              ),
            ),
            body: cubit.invoices == null
                ? (state is GetInvoicesError)
                    ? Center(
                        child: Text(
                        state.error.errors.values.first.first,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ))
                    : Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: RepaintBoundary(
                      key: _globalKey,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 20),
                        decoration: BoxDecoration(
                          color: MainCubit.get(context).isDark
                              ? ColorManager.myPetsBaseBlackColor
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xff000000).withOpacity(0.05),
                              blurRadius: 5,
                              spreadRadius: 4,
                              offset: Offset(0, 0),
                            ),
                          ],
                          border: Border.all(
                            color: MainCubit.get(context).isDark
                                ? ColorManager.myPetsBaseBlackColor
                                : Colors.white,
                            width: 0,
                            style: BorderStyle.solid,
                          ),
                        ),

                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        // elevation: 5.0,
                        margin: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 8.0,
                        ),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header with Logo and QR Code
                            Row(
                              mainAxisAlignment: cubit.invoices!.isNeedSaQrCode
                                  ? MainAxisAlignment.spaceBetween
                                  : MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 100,
                                  child: CachedNetworkImage(
                                    imageUrl: ConfigModel
                                            .serverFirstHalfOfImageimageUrl +
                                        clinicImage,
                                    width: 150,
                                    height: 100,
                                  ),
                                ),
                                if (cubit.invoices!.isNeedSaQrCode)
                                  QrImageView(
                                    data: cubit.invoices!.saCode!,
                                    version: QrVersions.auto,
                                    size: 100.0,
                                  ),
                              ],
                            ),
                            SizedBox(height: 20),
                            // Clinic Info
                            _buildClinicInfo(context, cubit),

                            if (cubit.invoices!.zatcaNumber != '-')
                              Row(
                                children: [
                                  Text(
                                    S.of(context).crNumber,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                    cubit.invoices!.zatcaNumber!,
                                  ),
                                ],
                              ),
                            if (cubit.invoices!.zatcaNumber != '-')
                              SizedBox(
                                height: 8,
                              ),
                            if (cubit.invoices!.crNumber != '-')
                              Row(
                                children: [
                                  Text(
                                    S.of(context).vat,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                    cubit.invoices!.crNumber!,
                                  ),
                                ],
                              ),
                            SizedBox(height: 10),
                            // Pet Data
                            Text(
                              S.of(context).petDetails,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),

                            ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: cubit.pet!.species == '' ? 2 : 3,
                              itemBuilder: (context, index) {
                                return Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: MainCubit.get(context).isDark
                                              ? ThemeData.dark()
                                                  .scaffoldBackgroundColor
                                              : Color(0xFFF7F7F7),
                                          border: Border.all(
                                            color: Colors.grey,
                                            width: .5,
                                          ),
                                          borderRadius: (index == 0)
                                              ? BorderRadiusDirectional.only(
                                                  topStart: Radius.circular(8),
                                                )
                                              : (index == 2)
                                                  ? BorderRadiusDirectional
                                                      .only(
                                                      bottomStart:
                                                          Radius.circular(8),
                                                    )
                                                  : null,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Text(
                                            index == 0
                                                ? S.of(context).petName
                                                : index == 1 &&
                                                        cubit.pet!.species != ''
                                                    ? S.of(context).species
                                                    : S.of(context).sex,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey,
                                            width: .5,
                                          ),
                                          borderRadius: (index == 0)
                                              ? BorderRadiusDirectional.only(
                                                  topEnd: Radius.circular(8),
                                                )
                                              : (index == 2)
                                                  ? BorderRadiusDirectional
                                                      .only(
                                                      bottomEnd:
                                                          Radius.circular(8),
                                                    )
                                                  : null,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Text(
                                            index == 0
                                                ? cubit.pet!.petName
                                                : index == 1 &&
                                                        cubit.pet!.species != ''
                                                    ? cubit.pet!.species
                                                    : cubit.pet!.sex,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),

                            ///Owner
                            Text(
                              S.of(context).ownerDetails,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: 2,
                              itemBuilder: (context, index) {
                                return Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: MainCubit.get(context).isDark
                                              ? ThemeData.dark()
                                                  .scaffoldBackgroundColor
                                              : Color(0xFFF7F7F7),
                                          border: Border.all(
                                            color: Colors.grey,
                                            width: .5,
                                          ),
                                          borderRadius: (index == 0)
                                              ? BorderRadiusDirectional.only(
                                                  topStart: Radius.circular(8),
                                                )
                                              : (index == 1)
                                                  ? BorderRadiusDirectional
                                                      .only(
                                                      bottomStart:
                                                          Radius.circular(8),
                                                    )
                                                  : null,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Text(
                                            index == 0
                                                ? S.of(context).name
                                                : S.of(context).phone,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey,
                                            width: .5,
                                          ),
                                          borderRadius: (index == 0)
                                              ? BorderRadiusDirectional.only(
                                                  topEnd: Radius.circular(8),
                                                )
                                              : (index == 1)
                                                  ? BorderRadiusDirectional
                                                      .only(
                                                      bottomEnd:
                                                          Radius.circular(8),
                                                    )
                                                  : null,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Text(
                                            index == 0
                                                ? cubit.owner!.ownerName
                                                : cubit.owner!.phone,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),

                            SizedBox(height: 10),
                            // Invoice Details
                            if (cubit.invoices!.items.isNotEmpty)
                              _buildSectionTitle(isArabic()
                                  ? 'تفاصيل الفاتورة'
                                  : 'Item Details'),
                            if (cubit.invoices!.items.isNotEmpty)
                              SizedBox(height: 5),
                            if (cubit.invoices!.items.isNotEmpty)
                              _buildTableWithHeaders(
                                [
                                  [
                                    S.of(context).itemName,
                                    S.of(context).price,
                                    S.of(context).qty,
                                    S.of(context).total,
                                  ],
                                  ...cubit.invoices!.items.map((e) {
                                    return [
                                      e.itemName,
                                      e.price.toString(),
                                      e.quantity.toString(),
                                      e.total.toString(),
                                    ];
                                  })
                                ],
                                3,
                                context,
                              ),
                            SizedBox(height: 10),
                            // Total and Paid Amount
                            Text(
                              '${S.of(context).total}: ${cubit.invoices!.receiptTotal}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            if (cubit.invoices!.vat != 0) SizedBox(height: 5),
                            if (cubit.invoices!.vat != 0)
                              Text(
                                '${S.of(context).vat}: ${cubit.invoices!.vat}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            if (cubit.invoices!.vat != 0) SizedBox(height: 5),
                            if (cubit.invoices!.vat != 0)
                              Text(
                                '${S.of(context).totalAmount}: ${cubit.invoices!.totalAfterVatAndDiscount}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            SizedBox(height: 5),
                            Text(
                              '${S.of(context).paid}: ${cubit.invoices!.paid}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),

                            // Footer with Payment Details
                            if (cubit.invoices!.paymentHistories.isNotEmpty)
                              _buildSectionTitle(isArabic()
                                  ? 'تفاصيل الدفع'
                                  : 'Payment Details'),
                            if (cubit.invoices!.paymentHistories.isNotEmpty)
                              SizedBox(height: 5),

                            if (cubit.invoices!.paymentHistories.isNotEmpty)
                              _buildTableWithHeaders(
                                [
                                  [
                                    S.of(context).date,
                                    S.of(context).payment,
                                    S.of(context).value,
                                    S.of(context).paymentType,
                                  ],
                                  ...cubit.invoices!.paymentHistories.map((e) {
                                    return [
                                      e.paymentDate,
                                      e.paymentName.toString(),
                                      e.value.toString(),
                                      e.type.toString(),
                                    ];
                                  })
                                ],
                                1,
                                context,
                              ),
                            SizedBox(height: 10),
                            if (cubit.invoices!.returnAndExchangePolicy != null)
                              Center(
                                child: Text(
                                  cubit.invoices!.returnAndExchangePolicy!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: ColorTheme.primaryColor,
              foregroundColor: Colors.white,
              onPressed: () async {
                Uint8List imageBytes = await _capturePng();
                _saveAsPdf(imageBytes);
              },
              child: Icon(Icons.download),
            ),
          );
        },
      ),
    );
  }

  Future<Uint8List> _capturePng() async {
    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        Uint8List pngBytes = byteData.buffer.asUint8List();
        return pngBytes;
      } else {
        throw Exception("Failed to convert image to ByteData.");
      }
    } catch (e) {
      print(e);
      throw Exception("Failed to capture image.");
    }
  }

  Future<void> _saveAsPdf(Uint8List imageBytes) async {
    final pdf = pw.Document();

    final image = pw.MemoryImage(imageBytes);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Image(image),
          );
        },
      ),
    );

    // Save PDF or share it using the `Printing` package
    await Printing.sharePdf(
        bytes: await pdf.save(), filename: 'widget_image.pdf');
  }

  Widget _buildClinicInfo(context, UserAppointmentCubit cubit) {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 4,
      itemBuilder: (context, index) {
        if (clinicPhone.startsWith('11') ||
            clinicPhone.startsWith('10') ||
            clinicPhone.startsWith('12') ||
            clinicPhone.startsWith('15')) {
          clinicPhone = '0' + clinicPhone;
        }
        return Padding(
          padding: const EdgeInsets.only(
            bottom: 8.0,
          ),
          child: Row(
            children: [
              Text(
                index == 0
                    ? S.of(context).clinic
                    : index == 1
                        ? S.of(context).phone
                        : index == 2
                            ? S.of(context).invoiceNo
                            : S.of(context).date,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              Text(
                "${index == 0 ? cubit.invoices!.clinicName : index == 1 ? clinicPhone : index == 2 ? cubit.invoices!.invoiceCode : (formatBILL(cubit.invoices!.issueDate))}",
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildTableWithHeaders(
      List<List<String>> data, double width, context) {
    return Table(
      border: TableBorder.all(
        color: MainCubit.get(context).isDark ? Colors.black : Colors.grey,
        width: .5,
        borderRadius: BorderRadius.circular(8),
      ),
      columnWidths: {
        0: FlexColumnWidth(width),
        1: FlexColumnWidth(),
        2: FlexColumnWidth(),
        3: FlexColumnWidth(),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(
            color: MainCubit.get(context).isDark
                ? ThemeData.dark().scaffoldBackgroundColor
                : Color(0xFFF7F7F7),
          ),
          children: data.first.map((cell) {
            return Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                cell,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          }).toList(),
        ),
        ...data.skip(1).map((row) {
          return TableRow(
            children: row.map((cell) {
              return Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(cell),
              );
            }).toList(),
          );
        }).toList(),
      ],
    );
  }
}

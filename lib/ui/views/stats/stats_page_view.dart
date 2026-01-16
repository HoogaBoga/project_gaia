import 'package:flutter/material.dart';
import 'package:flutter_arc_text/flutter_arc_text.dart';
import 'package:percent_indicator/flutter_percent_indicator.dart';
import 'package:project_gaia/ui/views/stats/stats_page_viewmodel.dart';
import 'package:stacked/stacked.dart';

class StatsPageView extends StackedView<StatsPageViewmodel> {
  const StatsPageView({Key? key}) : super(key: key);

  @override
  void onViewModelReady(StatsPageViewmodel viewModel) {
    viewModel.initializeData();
  }

  @override
  Widget builder(
      BuildContext context, StatsPageViewmodel viewModel, Widget? child) {
    return Scaffold(
      backgroundColor: const Color(0xFF02213F),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Center(
              child: Text(
                "Gaia's Status",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Overall Health",
                      style: TextStyle(color: Color(0xFF6B6B6B), fontSize: 20)),
                  const Text(
                    "60%",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const Text(
                    "Good",
                    style: TextStyle(color: Color(0xFF6B6B6B)),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    height: 300,
                    width: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        _buildRing(
                            radius: 125.0,
                            percent: viewModel.waterLevel,
                            color: const Color(0xFF1250AE),
                            text: "Water"),
                        _buildRing(
                            radius: 100.0,
                            percent: viewModel.humidityLevel,
                            color: const Color(0xFF12C8ED),
                            text: "Humidity"),
                        _buildRing(
                            radius: 75.0,
                            percent: viewModel.sunlightLevel,
                            color: const Color(0xFFEDBA12),
                            text: "Sunlight"),
                        _buildRing(
                            radius: 50.0,
                            percent: viewModel.temperatureLevel,
                            color: const Color(0xFFED5712),
                            text: "Temperature")
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  _buildLegend(
                      Icons.water,
                      "Water",
                      "${(viewModel.waterLevel * 100).toDouble()}%",
                      const Color(0xFF1250AE)),
                  _buildLegend(
                      Icons.cloud,
                      "Humidity",
                      "${(viewModel.humidityLevel * 100).toDouble()}%",
                      const Color(0xFF12C8ED)),
                  _buildLegend(
                      Icons.sunny,
                      "Sunlight",
                      "${(viewModel.sunlightLevel * 100).toDouble()}%",
                      const Color(0xFFEDBA12)),
                  _buildLegend(
                      Icons.thermostat,
                      "Temperature",
                      "${(viewModel.temperatureLevel * 100).toDouble()}%",
                      const Color(0xFFED5712))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRing(
      {required double radius,
      required double percent,
      required Color color,
      required String text}) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircularPercentIndicator(
          radius: radius,
          percent: percent,
          progressColor: color,
          backgroundColor: Colors.white,
          lineWidth: 10.0,
          animation: true,
          circularStrokeCap: CircularStrokeCap.round,
        ),
        ArcText(
          radius: radius,
          text: text,
          textStyle: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
          startAngleAlignment: StartAngleAlignment.center,
          placement: Placement.outside,
          direction: Direction.clockwise,
        )
      ],
    );
  }

  Widget _buildLegend(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Text(
                label,
              )
            ],
          ),
          Text(value)
        ],
      ),
    );
  }

  @override
  StatsPageViewmodel viewModelBuilder(BuildContext context) =>
      StatsPageViewmodel();
}

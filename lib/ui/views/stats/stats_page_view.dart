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
            const SizedBox(height: 35),
            Column(
              children: [
                const SizedBox(
                  height: 30,
                ),
                const Text(
                  "OVERALL HEALTH",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    letterSpacing: 2.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      (viewModel.overallHealth * 100).toStringAsFixed(2),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30, // Hero Size
                        fontWeight: FontWeight.bold,
                        height: 1.0,
                      ),
                    ),
                    Text(
                      "%",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: viewModel.conditionColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: viewModel.conditionColor.withValues(alpha: 0.5),
                        width: 1.5),
                  ),
                  child: Text(
                    "Condition: ${viewModel.conditionLabel}",
                    style: TextStyle(
                      color: viewModel.conditionColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: 350,
              width: 350,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 250,
                    width: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      // No color, just shadow
                      color: Colors.transparent,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1250AE).withValues(alpha: 0.3),
                          blurRadius: 60,
                          spreadRadius: 20,
                        ),
                      ],
                    ),
                  ),
                  _buildRing(
                      radius: 155.0,
                      percent: viewModel.waterLevel,
                      color: const Color(0xFF1250AE),
                      text: "Water"),
                  _buildRing(
                      radius: 120.0,
                      percent: viewModel.humidityLevel,
                      color: const Color(0xFF12C8ED),
                      text: "Humidity"),
                  _buildRing(
                      radius: 85.0,
                      percent: viewModel.sunlightLevel,
                      color: const Color(0xFFEDBA12),
                      text: "Sunlight"),
                  _buildRing(
                      radius: 50.0,
                      percent: viewModel.temperatureLevel,
                      color: const Color(0xFFED5712),
                      text: "Temp") // Shortened "Temperature" to fit
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Column(
                    children: [
                      _buildGeminiInsight(viewModel),
                      const SizedBox(
                        height: 10,
                      ),
                      _buildLegend(
                          Icons.water_drop,
                          "Water",
                          "${viewModel.rawSoilMoisture.toInt()}%",
                          const Color(0xFF1250AE)),
                      _buildLegend(
                          Icons.cloud,
                          "Humidity",
                          "${viewModel.rawHumidity.toStringAsFixed(1)}%",
                          const Color(0xFF12C8ED)),
                      _buildLegend(
                          Icons.wb_sunny,
                          "Sunlight",
                          "${viewModel.rawLightIntensity.toInt()} lux",
                          const Color(0xFFEDBA12)),
                      _buildLegend(
                          Icons.thermostat,
                          "Temperature",
                          "${viewModel.rawTemperature.toStringAsFixed(1)}°C",
                          const Color(0xFFED5712))
                    ],
                  ),
                ),
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
          backgroundColor: Colors.white.withValues(alpha: 0.05),
          lineWidth: 12.0,
          animation: true,
          circularStrokeCap: CircularStrokeCap.round,
        ),
        ArcText(
          radius: radius,
          text: text,
          textStyle: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
          startAngleAlignment: StartAngleAlignment.center,
          placement: Placement.outside,
          direction: Direction.clockwise,
        )
      ],
    );
  }

  Widget _buildLegend(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0), // More breathing room
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2), // Glow effect background
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              )
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildGeminiInsight(StatsPageViewmodel viewModel) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08), // Subtle Glass effect
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.purpleAccent.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome,
                color: Colors.purpleAccent, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${viewModel.plantName}'s Analysis",
                  style: const TextStyle(
                    color: Colors.purpleAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                if (viewModel.isLoadingAnalysis)
                  Row(
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.purpleAccent.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${viewModel.plantName} is thinking…",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    viewModel.analysisText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.4,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  StatsPageViewmodel viewModelBuilder(BuildContext context) =>
      StatsPageViewmodel();
}

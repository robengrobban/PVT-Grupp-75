import 'package:flutter/material.dart';
import 'package:flutter_app/models/Medal.dart';
import 'package:flutter_app/models/medal_repository.dart';
import 'package:flutter_app/models/performed_route.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_app/theme.dart' as Theme;
import 'big_gradient_dialog.dart';

class RouteCompleteDialog extends StatelessWidget {
  const RouteCompleteDialog(this._route, this._medals);

  final PerformedRoute _route;
  final List<Medal> _medals;

  @override
  Widget build(BuildContext context) {
    return BigGradientDialogShell(
      title: "Good job!",
      titleSize: 24,
      showArrow: false,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Lottie.asset('assets/images/firework-animation.json',
            width: 70, height: 70),
        Text("You finished your walk",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        Text("Duration: ${_route.actualDuration ~/ 60} min",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text("Distance: ${(_route.distance / 1000).toStringAsFixed(2)} km",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        if (_medals.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 20),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text("You also earned ${_medals.length} medals!",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20)),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color:
                  Theme.AppColors.brandOrange[900].withOpacity(0.5),
                ),
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.only(top: 10),
                height: _medals.length * 70.0,
                width: 250,
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _medals.length,
                    itemBuilder: (context, index) {
                      return Row(children: [
                        ShaderMask(
                          child: ImageIcon(
                            AssetImage('assets/images/141054.png'),
                            size: 50,
                            color: MedalRepository().getColor(
                                _medals[index].type, _medals[index].value),
                          ),
                          shaderCallback: (Rect bounds) {
                            return LinearGradient(
                              colors: [
                                Colors.transparent,
                                MedalRepository().getColor(
                                    _medals[index].type,
                                    _medals[index].value)
                              ],
                              stops: [0.0, 0.5],
                            ).createShader(bounds);
                          },
                          blendMode: BlendMode.srcIn,
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(MedalRepository().getDescription(
                              _medals[index].type, _medals[index].value)),
                        )
                      ]);
                    }),
              ),
            ]),
          )
      ]),
    );
  }
}
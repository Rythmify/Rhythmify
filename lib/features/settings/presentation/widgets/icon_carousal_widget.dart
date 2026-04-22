import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class IconCarousalWidget extends StatefulWidget{
  final List<String> iconPaths;
  const IconCarousalWidget({super.key, required this.iconPaths});

  @override
  State<StatefulWidget> createState() => _IconCarousalState();
}

class _IconCarousalState extends State<IconCarousalWidget> with SingleTickerProviderStateMixin{
  final PageController _controller=PageController(
    viewportFraction: 0.5,
    initialPage: 1000
  );
  Ticker? _ticker;
  Duration _lastElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker=createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed){
    if(!_controller.hasClients) return;
    if(_lastElapsed == Duration.zero){
      _lastElapsed=elapsed;
      return;
    }
    final dt = (elapsed - _lastElapsed).inMilliseconds/1000.0;
    _lastElapsed=elapsed;
    final pageWidth = _controller.position.viewportDimension*_controller.viewportFraction;
    final speedMultiplier=1.5;
    _controller.jumpTo(_controller.offset + pageWidth*dt*speedMultiplier);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 0.5
        ),
      ),
      child: ClipOval(
        child: SizedBox(
          width: 200,
          height: 200,
          child: PageView.builder(
            controller: _controller,
            itemBuilder: (context, index) {
              final path=widget.iconPaths[index%widget.iconPaths.length];
              return Center
              (
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child:  Padding(
                    padding: const EdgeInsets.all(3),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(35),
                      child: Image.asset(path,fit: BoxFit.cover)
                    ),
                  ),
                )
              );
            },
          ),
        ),
      ),
    );
  }
}
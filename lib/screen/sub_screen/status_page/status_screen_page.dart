import 'package:flutter/material.dart';
import 'package:message_app/services/status2_services.dart';
import 'package:message_app/services/status_services.dart';
import 'package:message_app/constant/snakbar.dart';
import 'package:message_app/model/status_model.dart';
import 'package:message_app/screen/widget/util/status_util/animated_bar.dart';
import 'package:message_app/screen/widget/util/status_util/user_status.dart';

class StatusScreen extends StatefulWidget {
  final String userlistID;
  const StatusScreen({super.key, required this.userlistID});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  final PageController _pc = PageController();
  late AnimationController ac;
  List<StatusModel> statusList = [];

  var eachStatus;

  @override
  void initState() {
    super.initState();
    _pc;
    ac = AnimationController(vsync: this);
    fetchUserStatus();
  }

  Future<void> fetchUserStatus() async {
    try {
      statusList = await Status2Services.fetchUserStatus(widget.userlistID);
      if (statusList.isNotEmpty) {
        final ea = statusList[_currentIndex];
        setState(() {
          eachStatus = ea;
        });
        final firstStatus = statusList.first;
        _loadStory(eachStatus: firstStatus, animateToPage: false);

        ac.addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            ac.stop();
            ac.reset();
            setState(() {
              if (_currentIndex + 1 < statusList.length) {
                _currentIndex += 1;
                _loadStory(eachStatus: statusList[_currentIndex]);
              } else {
                _currentIndex = 0;
                _loadStory(eachStatus: statusList[_currentIndex]);
              }
            });
          }
        });
      } else {
        SnackBarUtil.showSnackBar('User Status is Empty', Colors.red);
        debugPrint('Empty');
      }
    } catch (e) {
      debugPrint('Cannot fetch User Status: ${e.toString()}');
    }
  }

  @override
  void dispose() {
    _pc.dispose();
    ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
      body: GestureDetector(
        onTapDown: (details) {
          _onTapDown(details, eachStatus);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Stack(
            children: [
              PageView.builder(
                controller: _pc,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: statusList.length,
                itemBuilder: (context, index) {
                  var eachElemet = statusList[index];

                  int lastIndex = statusList.length - 1;
                  if (index == lastIndex) {
                    debugPrint(lastIndex.toString());
                  }

                  String statusURL = eachElemet.statusURL;

                  return Image.network(
                    statusURL,
                  );
                },
              ),
              Positioned(
                top: 40,
                left: 10,
                right: 10,
                child: Column(
                  children: [
                    Row(
                        children: statusList
                            .asMap()
                            .map((i, e) {
                              return MapEntry(
                                  i,
                                  AnimatedBar(
                                      animationController: ac,
                                      positon: i,
                                      currentIndex: _currentIndex));
                            })
                            .values
                            .toList()),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 2),
                      child: UserInfo(userId: widget.userlistID),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onTapDown(TapDownDetails details, final eachStatus) {
    final double mywidth = MediaQuery.of(context).size.width;
    final double dx = details.globalPosition.dx;
    if (dx < mywidth / 3) {
      debugPrint('Left Screen');
      setState(() {
        if (_currentIndex - 1 >= 0) {
          _currentIndex -= 1;
          _loadStory(eachStatus: statusList[_currentIndex]);
        }
      });
    } else if (dx > 2 * mywidth / 3) {
      debugPrint('Right Screen');
      setState(() {
        if (_currentIndex + 1 < statusList.length) {
          _currentIndex += 1;
          _loadStory(eachStatus: statusList[_currentIndex]);
        } else {
          _currentIndex = 0;
          _loadStory(eachStatus: statusList[_currentIndex]);
        }
      });
    } else {
      debugPrint('Middle Screen');
    }
  }

  _loadStory({final eachStatus, bool animateToPage = true}) {
    ac.stop();
    ac.reset();
    ac.duration = const Duration(seconds: 15);
    ac.forward();

    if (animateToPage) {
      _pc.animateToPage(_currentIndex,
          duration: const Duration(milliseconds: 1), curve: Curves.easeInOut);

      String statusID = statusList[_currentIndex].statusID;
      StatusServices.updateSeenStatus(widget.userlistID, statusID, statusList);
    }
    if (!animateToPage) {
      String statusID = statusList[_currentIndex].statusID;
      StatusServices.updateSeenStatus(widget.userlistID, statusID, statusList);
    }
  }
}

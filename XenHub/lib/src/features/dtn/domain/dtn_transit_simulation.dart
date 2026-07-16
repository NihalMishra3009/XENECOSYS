import 'dtn_bus.dart';
import 'dtn_hub.dart';

class DtnTransitInfo {
  const DtnTransitInfo({
    required this.status,
    required this.phaseLabel,
    required this.positionLabel,
    required this.nextEventLabel,
    required this.timeToNextEvent,
    required this.timeSinceLastEvent,
    required this.progress,
  });

  final String status;
  final String phaseLabel;
  final String positionLabel;
  final String nextEventLabel;
  final Duration timeToNextEvent;
  final Duration timeSinceLastEvent;
  final double progress;
}

class DtnTransitSimulation {
  static const Duration loadingDuration = Duration(minutes: 1);
  static const Duration destinationWaitDuration = Duration(minutes: 1);
  static const Duration originWaitDuration = Duration(minutes: 1);

  static DtnTransitInfo fromBus(
    DtnBus bus,
    List<DtnHub> hubs,
    DateTime now,
  ) {
    final originHub = _hubName(hubs, bus.originHubId);
    final destinationHub = _hubName(hubs, bus.destinationHubId);
    final travelDuration = _travelDurationFor(bus);
    final cycleDuration = loadingDuration +
        travelDuration +
        destinationWaitDuration +
        travelDuration +
        originWaitDuration;
    final offset = Duration(
      seconds: (bus.id * 37 + bus.originHubId * 11 + bus.destinationHubId * 17) %
          cycleDuration.inSeconds,
    );
    final secondsIntoCycle = now
        .add(offset)
        .millisecondsSinceEpoch
        .remainder(cycleDuration.inMilliseconds) ~/
        1000;

    if (secondsIntoCycle < loadingDuration.inSeconds) {
      final elapsed = Duration(seconds: secondsIntoCycle);
      return DtnTransitInfo(
        status: 'loading',
        phaseLabel: 'Dispatching',
        positionLabel: 'At $originHub',
        nextEventLabel: 'Dispatch in',
        timeToNextEvent: loadingDuration - elapsed,
        timeSinceLastEvent: elapsed,
        progress: elapsed.inSeconds / loadingDuration.inSeconds,
      );
    }

    if (secondsIntoCycle < loadingDuration.inSeconds + travelDuration.inSeconds) {
      final elapsed = Duration(seconds: secondsIntoCycle - loadingDuration.inSeconds);
      return DtnTransitInfo(
        status: 'in-transit',
        phaseLabel: 'In transit',
        positionLabel: 'Between $originHub and $destinationHub',
        nextEventLabel: 'Arrival in',
        timeToNextEvent: Duration(
          seconds: loadingDuration.inSeconds + travelDuration.inSeconds - secondsIntoCycle,
        ),
        timeSinceLastEvent: Duration(seconds: secondsIntoCycle - loadingDuration.inSeconds),
        progress: elapsed.inSeconds / travelDuration.inSeconds,
      );
    }

    if (secondsIntoCycle <
        loadingDuration.inSeconds +
            travelDuration.inSeconds +
            destinationWaitDuration.inSeconds) {
      final elapsed = Duration(
        seconds: secondsIntoCycle -
            loadingDuration.inSeconds -
            travelDuration.inSeconds,
      );
      return DtnTransitInfo(
        status: 'waiting',
        phaseLabel: 'Holding',
        positionLabel: 'At $destinationHub',
        nextEventLabel: 'Return dispatch in',
        timeToNextEvent: Duration(
          seconds: loadingDuration.inSeconds +
              travelDuration.inSeconds +
              destinationWaitDuration.inSeconds -
              secondsIntoCycle,
        ),
        timeSinceLastEvent: elapsed,
        progress: elapsed.inSeconds / destinationWaitDuration.inSeconds,
      );
    }

    if (secondsIntoCycle <
        loadingDuration.inSeconds +
            travelDuration.inSeconds +
            destinationWaitDuration.inSeconds +
            travelDuration.inSeconds) {
      final elapsed = Duration(
        seconds: secondsIntoCycle -
            loadingDuration.inSeconds -
            travelDuration.inSeconds -
            destinationWaitDuration.inSeconds,
      );
      return DtnTransitInfo(
        status: 'in-transit',
        phaseLabel: 'In transit',
        positionLabel: 'Between $destinationHub and $originHub',
        nextEventLabel: 'Arrival in',
        timeToNextEvent: Duration(
          seconds: loadingDuration.inSeconds +
              travelDuration.inSeconds +
              destinationWaitDuration.inSeconds +
              travelDuration.inSeconds -
              secondsIntoCycle,
        ),
        timeSinceLastEvent: elapsed,
        progress: elapsed.inSeconds / travelDuration.inSeconds,
      );
    }

    final elapsed = Duration(
      seconds: secondsIntoCycle -
          loadingDuration.inSeconds -
          travelDuration.inSeconds -
          destinationWaitDuration.inSeconds -
          travelDuration.inSeconds,
    );
    return DtnTransitInfo(
      status: 'loading',
      phaseLabel: 'Dispatching',
      positionLabel: 'At $originHub',
      nextEventLabel: 'Dispatch in',
      timeToNextEvent: Duration(seconds: originWaitDuration.inSeconds - elapsed.inSeconds),
      timeSinceLastEvent: elapsed,
      progress: elapsed.inSeconds / originWaitDuration.inSeconds,
    );
  }
}

Duration _travelDurationFor(DtnBus bus) {
  if (bus.name == 'North Relay 01') {
    return const Duration(minutes: 15);
  }
  return const Duration(minutes: 10);
}

String _hubName(List<DtnHub> hubs, int hubId) {
  for (final hub in hubs) {
    if (hub.id == hubId) {
      return hub.name;
    }
  }
  return 'Hub $hubId';
}

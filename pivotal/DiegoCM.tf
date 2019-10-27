resource "signalfx_detector" "pivotal_cloudfoundry_DCM_errors" {
  name         = "[SFx] Pivotal cloudFoundry Diego Ceel Metrics errors"
  description  = "Alerts for various Pivotal CloudFoundry Log related error scenarios"
  program_text = <<-EOF


from signalfx.detectors.against_periods import against_periods
from signalfx.detectors.against_recent import against_recent
from signalfx.detectors.not_reporting import not_reporting
from signalfx.detectors.countdown import countdown

A = data('rep.CapacityRemainingDisk', filter=filter('metric_source', 'cloudfoundry'), rollup='min').mean().publish(label='CapacityRemainingDisk', enable=True)
CapacityRemainingDisk = (A/1000).mean(over='5m').publish(label='B', enable=True)
CPM = data('rep.CapacityRemainingMemory', filter=filter('metric_source', 'cloudfoundry'), rollup='min').mean().publish(label='CPM', enable=True)
CapacityRemainingMemory = (CPM/1024).publish(label='B', enable=True)

not_reporting.detector(stream=CPM, resource_identifier=None, duration='15m').publish('Pivotal Cloudfoundry - CapacityRemainingMemory not being reported.')
detect(when((CapacityRemainingMemory > 32) and (CapacityRemainingMemory <= 64))).publish('Pivotal Cloudfoundry - CapacityRemainingMemory 5 Minute Minumum is within 32GB  and 64GB.')
detect(when(CapacityRemainingMemory <= 32)).publish('Pivotal Cloudfoundry - CapacityRemainingMemory 5 Minute Minumum is less or Equal to 32GB.') 
countdown.hours_left_stream_detector(stream=CapacityRemainingDisk, minimum_value=6, lower_threshold=48, fire_lasting=lasting('12m', 0.95), clear_threshold=60, clear_lasting=lasting('12m', 0.95), use_double_ewma=False).publish('Pivotal Cloudfoundry - CapacityRemainingDisk - (assumed to be decreasing) is projected to decrease to 6 in 48 hour(s).')

    EOF
  rule {
    detect_label = "Pivotal Cloudfoundry - CapacityRemainingMemory not being reported."
    severity     = "Minor"
  }
 rule {
    detect_label = "Pivotal Cloudfoundry - CapacityRemainingMemory 5 Minute Minumum is within 32GB  and 64GB."
    severity     = "Minor"
  }
  rule {
    detect_label = "Pivotal Cloudfoundry - CapacityRemainingMemory 5 Minute Minumum is less or Equal to 32GB."
    severity     = "Critical"
  }
 rule {
    detect_label = "Pivotal Cloudfoundry - CapacityRemainingDisk - (assumed to be decreasing) is projected to decrease to 6 in 48 hour(s)."
    severity     = "Critical"
  }

}
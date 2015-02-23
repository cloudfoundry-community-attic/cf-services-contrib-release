---
title: RabbitMQ service broker
---

## <a id="intro"></a>Introduction

The RabbitMQ service broker was donated by Pivotal in June 2013, cf [announcement](https://groups.google.com/a/cloudfoundry.org/d/msg/vcap-dev/To0E1kBB-6E/dG9CiNu9F6oJ) "There are interesting and ambitious ideas in this repo, but we don't know if they work"


## <a id="architecture"></a>Architecture

the broker supports the service broker V1 REST API.
the gateway communicates with each node using nats.

![](http://www.plantuml.com/plantuml/svg/YtPsZbMmqTMrKuWkIanAoYp9BOnFJon9BK-iZBLI24ujAijCJbL8AihFJYrI23DK278D3b5m3F3ambIERanUVagg0T2GlCIIOYAL6yAK0m00)



Then within each rabbitmq_node, a rabbit_node process handling the nats message is dynamically instanciating warden containers that host one rabbitmq process (corresponding to one service instance), stores the list of containers into a sqllite localdb, and communicates with each rabbitmq process for binding/unbinding and creating per-binding credentials. The warden containers apply some limits to the rabbit processes (such as ram, disk and bandwidth), while the daylimit daemon is dynamically modifying the bandwidth of the containers by inspecting the actual transmitted traffic over each warden container virtual nic.

![](http://www.plantuml.com/plantuml/png/oyjFILLGAafCIieioIsCpmDobHIgkHI081eY2XQBnHHHqDMrKuWkJonAISrJICxFAqdCp4ijCeorKe2A5USdP-FGLboOarcIogMENHRc6aEmxfJ4aiIan6AWAo6wb21cfYHMvcJcPfR4Se7v1Od9sOdfG4KO3e9v1s4Lq6I8VshnQpN2fjK8fhMM2m00)





## <a id="limitations"></a>Known limitations

* Default bandwidth applied in default service plan by spiff templates adds up significant latency, resulting in slow transmitted message rates, and potentially connection closing initiations from either rabbitmq client or servers (triggering transaction rollbacks).
* When a warden container gets killed, the rabbitmq_node job is unable to unprovision users within it and fails. This appears to the rabbit_mq broker as a timeout or "binding id not found" .
* Some connection errors with nats have been reported, resulting into rabbitmq_node flapping (keep restarting, stopping all rabbitmq warden containers during stop)
* Broker error condition returning "Service broker error: Unknown plan default"

## <a id="alternatives"></a>Alternatives

[cf-rabbitmq-release](https://github.com/pivotal-cf/cf-rabbitmq-release) was opensourced by pivotal in early 2015 and supports the V2 API, and is the base for pivotal commercial rabbit mq service. See [announcement](https://groups.google.com/a/cloudfoundry.org/d/msg/vcap-dev/LAwNKw_pJak/_kIplnXADVIJ)


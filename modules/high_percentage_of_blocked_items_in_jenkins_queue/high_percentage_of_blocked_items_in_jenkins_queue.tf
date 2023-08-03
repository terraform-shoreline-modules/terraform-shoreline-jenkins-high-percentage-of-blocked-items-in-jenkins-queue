resource "shoreline_notebook" "high_percentage_of_blocked_items_in_jenkins_queue" {
  name       = "high_percentage_of_blocked_items_in_jenkins_queue"
  data       = file("${path.module}/data/high_percentage_of_blocked_items_in_jenkins_queue.json")
  depends_on = [shoreline_action.invoke_check_build_agent_status,shoreline_action.invoke_jenkins_status_check,shoreline_action.invoke_jenkins_increase_executors]
}

resource "shoreline_file" "check_build_agent_status" {
  name             = "check_build_agent_status"
  input_file       = "${path.module}/data/check_build_agent_status.sh"
  md5              = filemd5("${path.module}/data/check_build_agent_status.sh")
  description      = "An issue with the build agents, such as agents being offline or misconfigured, causing the high percentage of blocked items in the queue."
  destination_path = "/agent/scripts/check_build_agent_status.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "jenkins_status_check" {
  name             = "jenkins_status_check"
  input_file       = "${path.module}/data/jenkins_status_check.sh"
  md5              = filemd5("${path.module}/data/jenkins_status_check.sh")
  description      = "An issue with the Jenkins server, such as a bug in the Jenkins software or an overload of the server, causing the high percentage of blocked items in the queue."
  destination_path = "/agent/scripts/jenkins_status_check.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "jenkins_increase_executors" {
  name             = "jenkins_increase_executors"
  input_file       = "${path.module}/data/jenkins_increase_executors.sh"
  md5              = filemd5("${path.module}/data/jenkins_increase_executors.sh")
  description      = "Increase the number of executors on the Jenkins server to improve job processing and reduce queue blockages."
  destination_path = "/agent/scripts/jenkins_increase_executors.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_check_build_agent_status" {
  name        = "invoke_check_build_agent_status"
  description = "An issue with the build agents, such as agents being offline or misconfigured, causing the high percentage of blocked items in the queue."
  command     = "`chmod +x /agent/scripts/check_build_agent_status.sh && /agent/scripts/check_build_agent_status.sh`"
  params      = ["NAME_OF_BUILD_AGENT","BUILD_AGENT_URL"]
  file_deps   = ["check_build_agent_status"]
  enabled     = true
  depends_on  = [shoreline_file.check_build_agent_status]
}

resource "shoreline_action" "invoke_jenkins_status_check" {
  name        = "invoke_jenkins_status_check"
  description = "An issue with the Jenkins server, such as a bug in the Jenkins software or an overload of the server, causing the high percentage of blocked items in the queue."
  command     = "`chmod +x /agent/scripts/jenkins_status_check.sh && /agent/scripts/jenkins_status_check.sh`"
  params      = ["JENKINS_URL"]
  file_deps   = ["jenkins_status_check"]
  enabled     = true
  depends_on  = [shoreline_file.jenkins_status_check]
}

resource "shoreline_action" "invoke_jenkins_increase_executors" {
  name        = "invoke_jenkins_increase_executors"
  description = "Increase the number of executors on the Jenkins server to improve job processing and reduce queue blockages."
  command     = "`chmod +x /agent/scripts/jenkins_increase_executors.sh && /agent/scripts/jenkins_increase_executors.sh`"
  params      = ["JENKINS_API_TOKEN","NEW_EXECUTORS","JENKINS_URL"]
  file_deps   = ["jenkins_increase_executors"]
  enabled     = true
  depends_on  = [shoreline_file.jenkins_increase_executors]
}


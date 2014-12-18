# == Class: tomcat::service::archive
#
# This class configures the tomcat service when installed from archive
#
class tomcat::service::archive {
  # The base class must be included first
  if !defined(Class['tomcat']) {
    fail('You must include the tomcat base class before using any tomcat sub class')
  }

  # systemd is prefered if supported
  if $::operatingsystem == 'Fedora' or ($::osfamily == 'RedHat' and $::operatingsystem != 'Fedora' and $::operatingsystemmajrelease >= 7) {
    file { "${::tomcat::service_name_real} service unit":
      path    => "/usr/lib/systemd/system/${::tomcat::service_name_real}.service",
      owner   => 'root',
      group   => 'root',
      content => template("${module_name}/instance/systemd_unit.erb")
    }

    service { $::tomcat::service_name_real:
      ensure  => $::tomcat::service_ensure,
      enable  => $::tomcat::service_enable,
      require => File["${::tomcat::service_name_real} service unit"]
    }
  } else { # temporary solution until a proper init script is included
    $catalina_script = "${::tomcat::catalina_home_real}/bin/catalina.sh"
    $start_command = "export CATALINA_BASE=${::tomcat::catalina_base_real}; /bin/su ${::tomcat::tomcat_user_real} -s /bin/bash -c '${catalina_script} start'"
    $stop_command = "export CATALINA_BASE=${::tomcat::catalina_base_real}; /bin/su ${::tomcat::tomcat_user_real} -s /bin/bash -c '${catalina_script} stop'"
    $status_command = "/usr/bin/pgrep -d , -u ${::tomcat::tomcat_user_real} -G ${::tomcat::tomcat_group_real} -f Dcatalina.base=${::tomcat::catalina_base_real}"

    service { $::tomcat::service_name_real:
      ensure   => $::tomcat::service_ensure,
      enable   => $::tomcat::service_enable,
      provider => 'base',
      start    => $start_command,
      stop     => $stop_command,
      status   => $status_command
    }
  }
}
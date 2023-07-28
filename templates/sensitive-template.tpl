%{ for header in sensitiveHeaders ~}
  <set-header name="${header}" exists-action="delete" />
%{ endfor ~}
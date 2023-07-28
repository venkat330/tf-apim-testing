    <cors allow-credentials="true">
      <allowed-origins>
        <origin>@(context.Request.OriginalUrl.Host.ToString( ))</origin>
        %{ for origin in allowedOrigins ~}
        <origin>${origin}</origin>
        %{ endfor ~}
      </allowed-origins>
      <allowed-methods preflight-result-max-age="300">
        %{ for method in allowedMethods ~}
        <method>${method}</method>
        %{ endfor ~}
      </allowed-methods>
      <allowed-headers>
        %{ for header in allowedHeaders ~}
        <header>${header}</header>
        %{ endfor ~}
      </allowed-headers>
    </cors>
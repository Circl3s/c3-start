Import-Module Pode

Start-PodeServer {
    Add-PodeEndpoint -Address localhost -Port 1234 -Protocol Http

    Set-PodeViewEngine -Type Pode

    Add-PodeRoute -Method GET -Path "/" -ScriptBlock {
        Write-PodeViewResponse -Path "index"
    }

    Add-PodeRoute -Method GET -Path "/info" -ScriptBlock {
        $Counters = Get-Counter '\Processor(_Total)\% Processor Time', '\Memory\Available MBytes'
        $CPU = $Counters.CounterSamples[0].CookedValue
        $RAM = $Counters.CounterSamples[1].CookedValue
        $Processes = (Get-Process).Length
        $Now = Get-Date
        $DOW = $Now.DayOfWeek.ToString()
        $Date = $Now.ToLongDateString()
        Write-PodeJsonResponse -Value @{"processes" = $Processes; "cpu" = $CPU; "ram" = $RAM; "day" = $DOW; "date" = $Date}
    }

    Add-PodeRoute -Method POST,GET -Path "/launch/:path" -ScriptBlock {
        Start-Process $WebEvent.Parameters["path"]
        Write-PodeJsonResponse -Value @{"success" = $?}
    }
}
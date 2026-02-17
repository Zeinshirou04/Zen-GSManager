@{
    Slots = @{
        Active  = "E"
        Storage = "F"
    }

    Safety = @{
        AbortWhenUnmanaged   = $true
        MaxUnmanagedExamples = 5
    }

    Robocopy = @{
        RetryCount  = 2
        WaitSeconds = 2
        MultiThread = 8
        Verbose = $true
        VerboseByDefault = $true
    }

    Logging = @{
        LogFolder = "Logs"
    }

    Application = @{
        Version = "1.2.1"
    }
}

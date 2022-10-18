param([String]$action) 
Add-Type -AssemblyName System.Windows.Forms

Add-Type @"
using System;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Text;

public struct RECT
{
    public int left;
    public int top;
    public int right;
    public int bottom;
}

public class pInvoke
{
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);

    [DllImport("user32.dll", CharSet = CharSet.Auto, CallingConvention = CallingConvention.StdCall, ExactSpelling = true, SetLastError = true)]
    public static extern bool GetWindowRect(IntPtr hWnd, ref RECT rect);
}
"@

function Move-Window([System.IntPtr]$WindowHandle, [switch]$Top, [switch]$Bottom, [switch]$Left, [switch]$Right, [int]$height, [int]$width, [int]$x, [int]$y) {
    $rect = New-Object RECT
    [pInvoke]::GetWindowRect($WindowHandle, [ref]$rect)
    [pInvoke]::MoveWindow($WindowHandle, $X, $Y, $width, $height, $true)
}

$windows = @{}

function Get-Window([System.IntPtr]$WindowHandle, $name){
    Write-Host '-----'
    Write-Host 'Name: ' $name

    $rect = New-Object RECT
    [pInvoke]::GetWindowRect($WindowHandle, [ref]$rect) > $null

    # get which screen the app has been spawned into
    $activeScreen = [System.Windows.Forms.Screen ]::FromHandle($WindowHandle).Bounds
    $x = $rect.left
    Write-Host "X:"         $x
    $y = $rect.top
    Write-Host "Y:"         $y
    $width = ($rect.right - $rect.left)
    Write-Host "Width:"     $width
    $height = ($rect.bottom - $rect.top)
    Write-Host "Height:"    $height
    
    $windows[$name] = @{}
    $windows[$name]['x'] = $x
    $windows[$name]['y'] = $y
    $windows[$name]['width'] = $width
    $windows[$name]['height'] = $height
}

function Snap {
    if((Get-CimInstance Win32_VideoController).MaxRefreshRate -eq 144){
        $windows = Get-Content "$PSScriptRoot\config.json" | Out-String | ConvertFrom-Json -AsHashtable
    } else {
        $windows = Get-Content "$PSScriptRoot\config2.json" | Out-String | ConvertFrom-Json -AsHashtable
    }

    if ($windows){
        ForEach ( $window in $windows.Keys){
            Write-Host $window
            $procID = Get-Process $window
            Move-Window -WindowHandle ($procID.MainWindowHandle | Where-Object {$_ -ne 0}) -x $windows[$window]['x'] -y $windows[$window]['y'] -width $windows[$window]['width'] -height $windows[$window]['height'] > $null
        }
    }
}

function Save {
    $processes = Get-Content "$PSScriptRoot\processes.json" | Out-String | ConvertFrom-Json -AsHashtable

    ForEach ( $process in $processes["processes"] ){
        Write-Host $process
        $procID = Get-Process $process
        Get-Window ($procID.MainWindowHandle | Where-Object {$_ -ne 0}) -name  $process
        
    }

    if((Get-CimInstance Win32_VideoController).MaxRefreshRate -eq 144){
        $windows | ConvertTo-Json -Depth 10 | Out-File $PSScriptRoot\config.json
        Write-Host "1"
    } else {
        $windows | ConvertTo-Json -Depth 10 | Out-File $PSScriptRoot\config2.json
        Write-Host "2"
    }
}

Write-Host $action
if ( $action -eq "snap" ){
    Snap 
} ElseIf ( $action -eq "save" ) {
    Save
}
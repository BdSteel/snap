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

#function Move-Window([System.IntPtr]$WindowHandle, [switch]$Top, [switch]$Bottom, [switch]$Left, [switch]$Right, [int]$height, [int]$width) {
function Move-Window([System.IntPtr]$WindowHandle, [switch]$Top, [switch]$Bottom, [switch]$Left, [switch]$Right, [int]$height, [int]$width, [int]$x, [int]$y) {
  # get the window bounds
  $rect = New-Object RECT
  [pInvoke]::GetWindowRect($WindowHandle, [ref]$rect)

  # get which screen the app has been spawned into
  $activeScreen = [System.Windows.Forms.Screen ]::FromHandle($WindowHandle).Bounds

  if ($Top) { # if top used, snap to top of screen
    $posY = $activeScreen.Top
  } elseif ($Bottom) { # if bottom used, snap to bottom of screen
    $posY = $activeScreen.Bottom - ($rect.bottom - $rect.top)
  } else { # if neither, snap to current position of the window
    $posY = $rect.top
  }

  if ($Left) { # if left used, snap to left of screen
    #$posX = $activeScreen.Left
    $posX = -1920
  } elseif ($Right) { # if right used, snap to right of screen
    $posX = $activeScreen.Right - ($rect.right - $rect.left)
  } else { # if neither, snap to current position of the window
    $posX = $rect.left
  }

  if(!$height){$height = $rect.bottom - $rect.top}
  if(!$width){$width = $rect.right - $rect.left}


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

$procID = Get-Process 'Chrome'
Get-Window ($procID.MainWindowHandle | Where-Object {$_ -ne 0}) -name  'Chrome'

$procID = Get-Process 'Discord'
Get-Window ($procID.MainWindowHandle | Where-Object {$_ -ne 0}) -name  'Discord'

$procID = Get-Process 'Steam'
Get-Window ($procID.MainWindowHandle | Where-Object {$_ -ne 0}) -name  'Steam'

$procID = Get-Process 'steamwebhelper'
Get-Window ($procID.MainWindowHandle | Where-Object {$_ -ne 0}) -name  'steamwebhelper'

$procID = Get-Process 'Spotify'
Get-Window ($procID.MainWindowHandle | Where-Object {$_ -ne 0}) -name  'Spotify'

if((Get-CimInstance Win32_VideoController).MaxRefreshRate -eq 144){
    $windows | ConvertTo-Json -Depth 10 | Out-File C:\Users\bdste\Documents\Repositories\Snap\config.json
    Write-Host "1"
} else {
    $windows | ConvertTo-Json -Depth 10 | Out-File C:\Users\bdste\Documents\Repositories\Snap\config2.json
    Write-Host "2"
}

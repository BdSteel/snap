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

$procID = Get-Process 'Chrome'
Move-Window -WindowHandle ($procID.MainWindowHandle | Where-Object {$_ -ne 0}) -x -1127 -y 0 -width 1134 -height 1047 > $null

$procID = Get-Process 'Discord'
Move-Window -WindowHandle ($procID.MainWindowHandle | Where-Object {$_ -ne 0}) -x -1920 -y 0 -width 800 -height 520 > $null

$procID = Get-Process 'Steam'
Move-Window -WindowHandle ($procID.MainWindowHandle | Where-Object {$_ -ne 0}) -x 0 -y 0 -width 1920 -height 1040 > $null

$procID = Get-Process 'steamwebhelper'
Move-Window -WindowHandle ($procID.MainWindowHandle | Where-Object {$_ -ne 0}) -x -1920 -y 520 -width 800 -height 520 > $null

$procID = Get-Process 'Spotify'
Move-Window -WindowHandle ($procID.MainWindowHandle | Where-Object {$_ -ne 0}) -x -1920 -y 0 -width 800 -height 1040 > $null
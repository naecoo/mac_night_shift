import { execSync } from "child_process";
import { showToast, Toast } from "@raycast/api";

/**
 * Execute a shell command and return the output
 */
export function execCommand(command: string): string {
  try {
    return execSync(command, { encoding: "utf-8", timeout: 10000 }).trim();
  } catch (error) {
    console.error(`Command failed: ${command}`, error);
    throw error;
  }
}

/**
 * Get current Night Shift status using Python and CoreBrightness framework
 * Returns true if enabled, false if disabled
 */
export function getNightShiftStatus(): boolean {
  try {
    const pythonScript = `
import objc
from Foundation import NSBundle

bundle = NSBundle.bundleWithPath_('/System/Library/PrivateFrameworks/CoreBrightness.framework')
bundle.load()

CBBlueLightClient = objc.lookUpClass('CBBlueLightClient')
client = CBBlueLightClient.alloc().init()

status = {'enabled': False}
client.getBlueLightStatus_(status)
print('1' if status.get('enabled', False) else '0')
`;

    const result = execCommand(`python3 -c '${pythonScript}'`);
    return result === "1";
  } catch (error) {
    console.error("Failed to get Night Shift status:", error);
    // Fallback: check if blue light reduction is enabled via defaults
    try {
      const result = execCommand("defaults read com.apple.CoreBrightness CBBlueLightReductionEnabled");
      return result === "1";
    } catch {
      return false;
    }
  }
}

/**
 * Set Night Shift enabled/disabled using Python and CoreBrightness framework
 */
export function setNightShiftEnabled(enabled: boolean): void {
  try {
    const pythonScript = `
import objc
from Foundation import NSBundle

bundle = NSBundle.bundleWithPath_('/System/Library/PrivateFrameworks/CoreBrightness.framework')
bundle.load()

CBBlueLightClient = objc.lookUpClass('CBBlueLightClient')
client = CBBlueLightClient.alloc().init()

client.setEnabled_(${enabled ? "True" : "False"})
`;

    execCommand(`python3 -c '${pythonScript}'`);
  } catch (error) {
    console.error("Failed to set Night Shift:", error);
    throw new Error(`Failed to ${enabled ? "enable" : "disable"} Night Shift`);
  }
}

/**
 * Toggle Night Shift
 */
export function toggleNightShift(): boolean {
  const currentStatus = getNightShiftStatus();
  const newStatus = !currentStatus;
  setNightShiftEnabled(newStatus);
  return newStatus;
}

/**
 * Show success toast
 */
export async function showSuccessToast(title: string, message?: string): Promise<void> {
  await showToast({
    style: Toast.Style.Success,
    title: title,
    message: message,
  });
}

/**
 * Show error toast
 */
export async function showErrorToast(message: string): Promise<void> {
  await showToast({
    style: Toast.Style.Failure,
    title: "Error",
    message: message,
  });
}

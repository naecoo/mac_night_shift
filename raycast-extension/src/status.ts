import { showHUD } from "@raycast/api";
import { getNightShiftStatus, showErrorToast } from "./utils";

export default async function Command() {
  try {
    const isEnabled = getNightShiftStatus();
    await showHUD(`Night Shift is ${isEnabled ? "on" : "off"}`);
  } catch (error) {
    await showErrorToast(error instanceof Error ? error.message : "Failed to get Night Shift status");
  }
}

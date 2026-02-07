import { showHUD } from "@raycast/api";
import { setNightShiftEnabled, showErrorToast } from "./utils";

export default async function Command() {
  try {
    setNightShiftEnabled(false);
    await showHUD("Night Shift turned off");
  } catch (error) {
    await showErrorToast(error instanceof Error ? error.message : "Failed to disable Night Shift");
  }
}

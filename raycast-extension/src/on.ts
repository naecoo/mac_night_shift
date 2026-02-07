import { showHUD } from "@raycast/api";
import { setNightShiftEnabled, showErrorToast } from "./utils";

export default async function Command() {
  try {
    setNightShiftEnabled(true);
    await showHUD("Night Shift turned on");
  } catch (error) {
    await showErrorToast(error instanceof Error ? error.message : "Failed to enable Night Shift");
  }
}

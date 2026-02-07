import { showHUD } from "@raycast/api";
import { toggleNightShift, showErrorToast } from "./utils";

export default async function Command() {
  try {
    const newState = toggleNightShift();
    await showHUD(`Night Shift turned ${newState ? "on" : "off"}`);
  } catch (error) {
    await showErrorToast(error instanceof Error ? error.message : "Failed to toggle Night Shift");
  }
}

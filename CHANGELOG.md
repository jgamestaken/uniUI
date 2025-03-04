![logo](https://github.com/user-attachments/assets/4889b3b7-8c18-4861-87a5-1ea289a8d98d)

# 4.0b4

- **Critical Bugfix**
  - uniUI.object.new - Function didn't immediately update because the function was using TweenService, a quick fix was implemented so that this now instantly sets all properties.

# 4.0b3

- **Deprecated functions**
  - uniUI.state.setall - Moved to uniUI.state.all.set
  - uniUI.base.ScreenGui - New function at uniUI.base.new
  - uniUI.base.SurfaceGui - New function at uniUI.base.new
  - uniUI.base.BillboardGui - New function at uniUI.base.new
- **New functions**
  - uniUI.base.new(basetype, parent, properties) - New, more simple to use base generation feature, sets all properties as untweenable property values.
  - uniUI.state.all.* - All normal "state" functions, except it will also affect descendants. Functions are .create, .set, .delete.
- **Bugs fixed**
  - uniUI.object.import - This function now also sets an empty "DEFAULT" state. The function will become more complete in the future.

# 4.0b2

- **Added Untweenable Properties(UTP)**
  - Edits properties that aren't Tweenable.
  - States now support UTP.
  - Script is still backwards compatible.
- **Bug fixes**
  - Fixed a bug affecting UI objects which don't have the .Active property.
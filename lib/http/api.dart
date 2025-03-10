import 'package:dim_example/im/info_handle.dart';
import 'package:dim_example/im/other/update_entity.dart';
import 'package:dim_example/provider/global_model.dart';
import 'package:dim_example/tools/wechat_flutter.dart';
import 'package:dim_example/ui/dialog/update_dialog.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';

/// 随机头像 [Random avatar]
void postSuggestionWithAvatar(BuildContext context) async {
  final model = Provider.of<GlobalModel>(context);

  Req.getInstance().get(
    API.cat,
    (v) async {
      String avatarUrl = v['url'];
      final data = await setUsersProfileMethod(
        context,
        avatarStr: avatarUrl,
        nickNameStr: model.nickName,
        callback: (data) {},
      );

      if (data.toString().contains('ucc')) {
        showToast(context, '设置头像成功');
        model.avatar = avatarUrl;
        model.refresh();
        await SharedUtil.instance.saveString(Keys.faceUrl, avatarUrl);
      } else {
        showToast(context, '设置头像失败');
      }
    },
  );
}

/// 检查更新 [check update]
void updateApi(BuildContext context) async {
  if (Platform.isIOS) return;
  Req.getInstance().get(
    API.update,
    (v) async {
      final packageInfo = await PackageInfo.fromPlatform();

      UpdateEntity model = UpdateEntity.fromJson(v);
      int currentVersion = int.parse(removeDot(packageInfo.version));
      int netVersion = int.parse(removeDot(model.appVersion));
      if (currentVersion >= netVersion) {
        debugPrint('当前版本是最新版本');
        return;
      }
      showDialog(
          context: context,
          builder: (ctx2) {
            return UpdateDialog(
              version: model.appVersion,
              updateUrl: model.downloadUrl,
              updateInfo: model.updateInfo,
            );
          });
    },
  );
}

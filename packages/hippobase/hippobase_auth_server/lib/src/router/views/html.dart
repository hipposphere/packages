String hippobaseAuthResetPasswordHtml(String appName, String token) =>
    '''<!doctype html>
<html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width"><title>Reset password</title></head>
<body><main><h1>${escapeHippobaseAuthHtml(appName)}</h1><form id="form"><input type="hidden" id="token" value="${escapeHippobaseAuthHtml(token)}"><label>New password <input id="password" type="password" minlength="8" required></label><button>Reset password</button><p id="status"></p></form></main>
<script>document.getElementById('form').addEventListener('submit',async(e)=>{e.preventDefault();const r=await fetch('../v1/user/reset-password',{method:'POST',headers:{'content-type':'application/json'},body:JSON.stringify({token:document.getElementById('token').value,new_password:document.getElementById('password').value})});document.getElementById('status').textContent=r.ok?'Password updated.':'Unable to reset password.';});</script></body></html>''';

String hippobaseAuthConfirmMailHtml(String appName, String token) =>
    '''<!doctype html>
<html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width"><title>Confirm email</title></head>
<body><main><h1>${escapeHippobaseAuthHtml(appName)}</h1><button id="confirm">Confirm email</button><p id="status"></p></main>
<script>document.getElementById('confirm').addEventListener('click',async()=>{const r=await fetch('../v1/user/confirm-mail',{method:'POST',headers:{'content-type':'application/json'},body:JSON.stringify({token:'${escapeHippobaseAuthJs(token)}'})});document.getElementById('status').textContent=r.ok?'Email confirmed.':'Unable to confirm email.';});</script></body></html>''';

String escapeHippobaseAuthHtml(String value) => value
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#39;');

String escapeHippobaseAuthJs(String value) => value.replaceAll(r'\', r'\\').replaceAll("'", r"\'");

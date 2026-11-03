import assert from 'node:assert/strict';

// This script intentionally has no production endpoint or project fallback.
const authBase = 'http://127.0.0.1:19099/identitytoolkit.googleapis.com/v1';
const dbBase = 'http://127.0.0.1:19000';
const namespace = 'demo-pinpotha-default-rtdb';
let passed = 0;
async function user(email) {
  const response = await fetch(`${authBase}/accounts:signUp?key=demo-key`, {
    method: 'POST', headers: {'Content-Type':'application/json'},
    body: JSON.stringify({email, password:'emulator-fixture-password', returnSecureToken:true}),
  });
  assert.equal(response.status, 200, await response.clone().text());
  return (await response.json()).idToken;
}
async function request(path, method, data, token) {
  const url = new URL(`${dbBase}/${path}.json`);
  url.searchParams.set('ns', namespace);
  if (token) url.searchParams.set('auth', token);
  return fetch(url, {method, headers: {'Content-Type':'application/json'}, body:data === undefined ? undefined : JSON.stringify(data)});
}
async function check(name, run) { await run(); passed++; console.log(`PASS ${name}`); }
const alice = await user('alice.fixture@example.com');
const bob = await user('bob.fixture@example.com');
const path = 'posts/alice,fixture@example,com/29-02-2020/legacy-post';
const fixture = {postId:'legacy-post', note:'පින් දහම්', photoUrl:'https://example.com/fixture-photo', timeStamp:{server_time:'1582934400000'}};
await check('existing wire schema is accepted under owner email path', async () => {
  const response = await request(path, 'PUT', fixture, alice); assert.equal(response.status, 200, await response.text());
});
await check('owner reads the same historical fields', async () => {
  const response = await request(path, 'GET', undefined, alice); assert.equal(response.status, 200); assert.deepEqual(await response.json(), fixture);
});
await check('other account cannot read or write owner path', async () => {
  assert.equal((await request(path, 'GET', undefined, bob)).status, 401);
  assert.equal((await request(path+'/note', 'PUT', 'intruder', bob)).status, 401);
});
await check('unauthenticated read and write are denied', async () => {
  assert.equal((await request(path, 'GET')).status, 401);
  assert.equal((await request(path, 'PUT', fixture)).status, 401);
});
await check('mismatched post ID is rejected', async () => {
  assert.equal((await request(path, 'PUT', {...fixture,postId:'wrong-id'}, alice)).status, 401);
});
await check('note-only edit preserves original timestamp and photo', async () => {
  const response = await request(path+'/note', 'PUT', 'updated', alice); assert.equal(response.status, 200);
  const after = await (await request(path, 'GET', undefined, alice)).json();
  assert.deepEqual(after, {...fixture,note:'updated'});
});
await check('owner deletion succeeds', async () => {
  assert.equal((await request(path, 'DELETE', undefined, alice)).status, 200);
  assert.equal(await (await request(path, 'GET', undefined, alice)).json(), null);
});
console.log(`${passed} Firebase rules compatibility checks passed against demo-pinpotha emulators.`);

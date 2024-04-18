import childProcess from 'node:child_process';
import * as path from 'node:path';

export default async function () {
  if (!import.meta.env.CI) {
    const label = 'Building test worker';
    console.time(label);
    childProcess.execSync('make build', {
      cwd: path.join(__dirname, '..'),
      stdio: 'pipe'
    });
    console.timeEnd(label);
  } else {
    console.log(
      'CI environment detected, skipping worker build. Will use previously built worker.'
    );
  }
}

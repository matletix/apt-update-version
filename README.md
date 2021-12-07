# apt-update-version

Bash script to install/update an apt package with custom sources to a specific version.
The custom apt sources are added during the script and removed when the script exits.

Usage : modify the necessary variables in the script before calling it :
```
./update_soft.sh <VERSION>
```

When multiple versions match the given version number, a choice to select a more specific version is offered. Example:
```
$ ./update_soft.sh 14

Found the following matching package versions for gitlab-ee :
0 => 14.5.2-ee.0
1 => 14.5.1-ee.0
2 => 14.5.0-ee.0
3 => 14.4.4-ee.0
4 => 14.4.3-ee.0
5 => 14.4.2-ee.0
6 => 14.4.1-ee.0
7 => 14.4.0-ee.0
8 => 14.3.6-ee.0
9 => 14.3.5-ee.0
10 => 14.3.4-ee.0
11 => 14.3.3-ee.0
[...]

Enter the index of the package you want to install (0..46), or "A" to abort :
```

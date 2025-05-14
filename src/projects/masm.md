---
title: String Primitives and Macros
---

[Source code for the project](https://github.com/erietz/osu-cs271-project6)

For my final project for CS271 (Computer Architecture and Assembly Language at
OSU) I wrote a program which prompts a user to enter 10 signed integers and
prints the numbers, their sum, and their average. If the user inputs a numbers
that is too large or too small to fit in a 32 bit register, or the user enters
characters that are not 0-9, they are repeatedly prompted to enter valid
numbers. This program uses Irvine's `ReadString` and `WriteString` procedures
to get the users input, but uses custom procedures to store the ascii strings
as signed integers internally. To print out the signed integers, the program
internally converts the signed integers back to ascii strings.

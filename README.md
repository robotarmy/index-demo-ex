# Bag Of Indexes



## BUILD

This will work with OSX / Unix

One way elixir and erlang can be installed is via homebrew on 
OSX or via ASDF across platforms

$ brew install elixir erlang

A general way to install elixir and erlang is via ASDF

https://asdf-vm.com/guide/getting-started.html#_3-install-asdf

installation of plugins to build these tools is best done with ASDF

$ asdf plugin-add elixir https://github.com/asdf-vm/asdf-elixir.git
$ asdf plugin add erlang https://github.com/asdf-vm/asdf-erlang.git


The ./index wrapper can be compiled then 

$ mix deps.get
$ mix escript.build

a test file can be generated depending on how many lines you like

streams are used to generate the file.

$ ./index test_input --generate=1000000

return the values of the top 10 keys 

$ ./index test_input --X=10


## Write-up

Thank you for the opportunity.

My Lanugage of preference currently is elixir or rust.
I have not worked extensively in Java or C++ for the last 10 years.
Please forgive my familiar choice.

The tool I wrote can be used to generate a test dataset of variety of sizes.
I admit that I was uncuccessful getting a performant build and search on 4.5GB of data.
The solution uses input steams to minimize memory usage while reading large files.

A trivial amount of data like 500MB was also quite slow at 60 seconds.

It would be interesting to compare these results in Rust which is not
designed to distrubte processes around a cluster and for high
performance concurrency and instead allows multable datastructures and shared memory.

Erlang uses tail call elimination in recursion and has no interative loop constructs.

I implemented this problem with 3 algorithums:

1) Naive Binary Tree
    It has an ok best case:

    Space O(n)
    Traverse O(log n)
    Insert O(log n)

    It has a terrible worst case as it devolves into a linked list depending on insert
    order and can become:
    Space O(n), Traverse O(n), Insert O(n)

    I wrote this as a warmup and to demonstrate that I can I can write basic code.

2) General Balanced Binary Tree / B-Tree

    A B-Tree is a manages the worst case of the Binary Tree
    by managing the height of the tree and balance of the nodes in a tree.
    The implementation is provided by someone much smarter than me and is built into the
    erlang general library.   https://user.it.uu.se/~arnea/ps/gb.pdf

    It makes the worst case of the Binary Tree disapear. O(log n)

    This is actually the place where the most interesting work would happen if one was
    developing a large scale distributed index ( for example) because the property of m
    children on a node can be exploited to establish a wide and low tree.

    A B*Tree or a order statistic tree modification could make writing a very massive index
    easier.

3. Heap and Ordered map

   I think a sophisticated maxheap implementation that keeps the index sorted would be the
   most performant - however it would have the largest cost in terms of building the index
   and require serialization and disk caching between loads.

   I put in a naive implementation to demonstrate that the majority of the work is actually
   in tuning and selecting an algorithum appropriate to system constraints. I used an 
   open source library.

   This is O(n log n) - in my experience quicksort is the best way to build and updated
   a list - but it would not be something you want to rebuild in realtime for a large dataset.

### Closing remarks.

    Obviously the most effective way to solve something like this in a toy would to use
    an appropriate database which has spent time and care to provide effective index ability
    I think the spirit of the question isn't to develop production quality code
    but to demonstrate ability to program.

    Thank you for the opportunity.

## Time Spent

2 hrs on initial Binary Tree Implementation and testing
2 hrs on writing loader
1 hrs on integrating Balanced Tree Implementation
2 hrs on genralizing loader, polishing, refactor code and benchmarking
1 hrs on unit-testing
1 hrs on integration MaxHeap
1 hrs on writing README


## Challenge Statement

Imagine a file in the following fixed format:
<unique record identifier><white_space><numeric value>
e.g.
1426828011 9
1426828028 350
1426828037 25
1426828056 231
1426828058 109
1426828066 111
.
.
.
Write a program that reads from 'stdin' the contents of a file, and optionally accepts
the absolute path of a file from the command line. The file/stdin stream is expected
to be in the above format. You may assume that the numeric value fits within a 32 bit
integer. The output should be a list of the unique ids associated with the X-largest
values in the rightmost column, where X is specified by an input parameter. For
example, given the input data above and X=3, the following would be valid output:

1426828028
1426828066
1426828056

Note that the output does not need to be in any particular order. 

Multiple instances of the same numeric value count as distinct records of the total X. 

So if we have 4
records with values: 200, 200, 115, 110 and X=2 then the result must consist of the two
IDs that point to 200 and 200 and no more.

Your solution should take into account extremely large files.
What to return back to us

1. Your code in the language of your preference. If it’s in Python, Java or C++ it’s
preferable for us.

2. Include in your code comments about your solution's algorithmic complexity
for both time and memory.

3. Include instructions on how to build and run your code in a README file.
Please include operating system information if necessary.

4. Provide tests for your code to illustrate it works and it’s robust.

5. Please zip everything in a directory named firstname.lastname/ and return

via email.

6. In your email response please let us know roughly how many hours you spent
for this exercise.




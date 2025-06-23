---
layout: post
title: "How to export saved URLs from the Safari Reading List"
date: 2024-07-28
tags: [Safari, Reading List, Scripts, Shell, Command Line]
---

If you use Safari's awesome Reading List feature, you may sometimes want to extract all URLs from this list for one of the following reasons:
- you want to export your saved articles to a different tool;
- you want to make sure they're backed up;
- you need to extract them to use in some automation.

In this article, I'll explain how to do this using the command line tools only.

If you're not interested in the details and just want **the script, it's available on [my GitHub](https://github.com/forketyfork/scripts/blob/main/bookmarks.sh)**. I tried to make it user-friendly and fail-safe, however, use it at your own risk and ensure you read it and understand what it does.

## How to find the Safari Reading List on the file system?

The Safari bookmarks, including the Reading List, are located in the `~/Library/Safari/Bookmarks.plist` file. This is a binary plist file, which means that you probably won't be able to just parse it using text processing tools. However, there's a standard macOS utility `plutil` that allows you to work with plist files.

Before running this utility though, **you should make a copy of this `Bookmarks.plist` file** and work with this copy, as the default behavior of plutil when extracting data is just to overwrite the file with whatever data you requested.

In my script, I copy the file to the temporary directory and do all operations on it, instead of the actual file:

```shell
bookmarks_file="$HOME/Library/Safari/Bookmarks.plist"
tmp_file=/tmp/Bookmarks.plist.tmp

# copy the Bookmarks.plist file to avoid overwriting it
cp "$bookmarks_file" $tmp_file
```

## How to extract the URLs from the Bookmarks.plist file?

At its root level, the `Bookmarks.plist` file contains the list of top-level bookmark folders. Those are the ones you see if you open the "Bookmarks" tab in Safari. We need the one that has the title `com.apple.ReadingList`  —  this is the special bookmark section that's displayed on the "Reading List" tab.

To find it, let's figure out how many children are at the root of the `Bookmarks.plist` file:

```shell
plutil -extract Children raw -expect array Bookmarks.plist
```

This command extracts the `Children` key from the file, expecting to get an array, and outputs the "raw" value of this array. The raw value of an array in terms of `plutil` is just the number of elements, so if you run this command on the `Bookmarks.plist` file, you should get a number, in my case, it was 18.

We can now iterate through those children elements to find the one that has the title `com.apple.ReadingList`:

```shell
for i in $(seq 0 17); do
  title="$(plutil -extract "Children.$i.Title" raw -expect string Bookmarks.plist)"
  if [ "$title" = "com.apple.ReadingList" ]; then
    echo "$i"
    break
  fi
done
```

Let's unwrap this:
- `seq 0 17` generates a sequence of numbers from 0 to 17 (as we had 18 sections in total). This is the sequence of array indices we iterate upon.
- Inside the loop, we run the command `plutil -extract "Children.$i.Title" raw -expect string Bookmarks.plist`, which extracts the title of each section, expecting to get a string;
- Once we find the section titled `com.apple.ReadingList`, we print out its index.

Now that we have the index (for me it was 3), let's count the number of articles in this section:

```shell
plutil -extract "Children.3.Children" raw -expect array Bookmarks.plist
```

Suppose we got 42 articles. Now the only thing we need to do is to iterate over those articles and print out the `URLString` property:

```shell
for i in $(seq 0 41); do
  plutil -extract "Children.3.Children.$i.URLString" raw -expect string Bookmarks.plist
done
```
All this is automated in my [script at GitHub](https://github.com/forketyfork/scripts/blob/main/bookmarks.sh), but again, make sure you understand it and use it at your own risk.

## Caveats

It's worth noting that the approach described here is not very performant. Each `plutil` call parses the file anew, so if you have many articles in your file, you're better off writing some custom code. For instance, you can convert the binary plist file to xml like this:

```shell
plutil -convert xml1 -o Bookmarks.xml.plist Bookmarks.plist
```

And then use an XML parser to extract the `URLString` values, or (with some luck and a bit of messy code) just grep them using regular expressions. But my intention here was to only use standard macOS command line tools and be precise with the extraction of data.
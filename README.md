# Cocoathin

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/cocoathin`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

<!--## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cocoathin'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cocoathin-->
    
    ## 
## intro
暂时只适用于Objc项目
`cocoathin`参考了[objcthin](https://github.com/svenJamy/objcthin)的部分解析`Mach-O`文件的代码，并在其基础上增加了更多的过滤功能，如pod引入的库等，使结果更准确


#### 原理
`cocoathin`通过命令行工具`otool`解析`Mach-O`文件,通过`dwarfdump`命令行工具解析`.a`文件，再经过正则过滤出无用类及方法

#### 注意
输出结果后仍然需要<font color=red>人工校验</font>后再删除

以下这些情况会<font color=red>找不到</font>

1. 只是被继承的类，被认定为Unused
2. 间接初始化的类被认定为Unused，如：

```Objc
//MYCell 被认定为 Unused
MYCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"xxx" forIndexPath:indexPath];
```

3. 假如`self`是	`UnusedModel`类，此种  `[[self alloc]init]` 调用，`UnusedModel`被认定为Unused
4. 等等

## Usage
需要 ruby >= 2.6
#### 这个gem还没有发布到https://rubygems.org，因此只能本地使用
#### clone后的时候方法
所有命令都是在项目所在目录
1. 构建
```ruby
bin/setup
bundle exec rake install 
```

2. 使用

`path` 为项目中 `Products/xxx.app`右键`show in Finder`后，`.app`的上层文件夹，
使用真机时就是`Debug-iphoneos`文件夹的路径

```ruby
# 找到有所得没有被引用的类 （ruby ./bin/cocoathin help findclass）
ruby ./bin/cocoathin findclass "/xx/xx/Debug-iphoneos"

# 找到有所得没有被引用的方法 （ruby ./bin/cocoathin help findcsel）
ruby ./bin/cocoathin findsel "/xx/xx/Debug-iphoneos"
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/cocoathin. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Cocoathin project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/cocoathin/blob/master/CODE_OF_CONDUCT.md).



